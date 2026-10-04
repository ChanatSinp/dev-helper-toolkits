# Go + Gin — hexagonal (ports and adapters)

Read when a brief, the user, or the project's `CLAUDE.md` asks for the hexagonal pattern on a Go/Gin service. It fixes where code goes and which way imports point; naming and style still come from `../code-conventions/go.md`. An existing project's own layout and `.claude/CLAUDE.md` win where they differ — match the code that is there, and report the difference rather than restructuring it.

The examples use one vertical, `order`, in a module named `app`.

## Layout

```
cmd/main.go                          composition root — the only place that constructs and wires
internal/
  core/                              no Gin, no SQL, no HTTP client
    domain/                          plain structs, constants, error codes — no `db` or `binding` tags
    port/inbound/                    I<Name>Port — what the core offers; input/output structs
    port/outbound/                   I<Name>Gateway — external services the core calls
    port/outbound/repository/        I<Name>Repository + IRepositoryFactory
    service/                         <Name>Service — implements an inbound port
  adapter/
    inbound/
      routes/                        IRouteService: engine, groups, middleware, request binding
      handler/                       shared response helpers (success, error-code → HTTP status)
      handler/<vertical>/            package <vertical>_hdl: handler.go, dto.go, middleware.go
      scheduler/                     background loops — an inbound adapter like a handler
    outbound/
      db/                            <name>.go repository per aggregate + factory.go
      db/postgresql/                 driver wrapper, tx manager; postgresqldb/ row structs + query keys; sql/*.sql
      db/cache/                      driver wrapper; cachedb/ key builders
      <service>/                     gateway implementing an outbound port
  configs/                           environment loading, IEnvService
  pkg/                               cross-cutting, importable by every layer: errors, contexts, logs, utils
```

## Dependency rule

| Package | May import | Never imports |
|---|---|---|
| `core/domain` | standard library | anything else in the module |
| `core/port/*` | `core/domain`, `pkg` | `core/service`, `adapter` |
| `core/service` | `core/domain`, `core/port/*`, `pkg`, `configs` | `adapter`, another service |
| `adapter/inbound/*` | `core/port/inbound`, `core/domain`, `pkg`, `routes` | `core/service`, `adapter/outbound`, `core/port/outbound` |
| `adapter/outbound/*` | `core/port/outbound/*`, `core/domain`, `pkg`; `core/port/inbound` only for a core capability a gateway needs (request signing), injected in `cmd` | `core/service`, `adapter/inbound` |
| `cmd` | everything | — |

- **A service never calls another service.** A service owns its own repositories and gateways only. Sequencing that spans services belongs to the inbound adapter that needs it.
- **Constructors return the interface**, never the struct: `NewOrderService(...) inbound.IOrderPort`.
- **The context wrapper carries the Gin context for adapters only.** `core` uses `ctx.GetContext()` and `ctx.GetLogger()`; calling `ctx.GetGinContext()` inside `core` is a violation.

## One vertical, layer by layer

**Domain** — `internal/core/domain/order.go`, with codes in `error.go`:

```go
type OrderData struct {
	OrderUuid    string
	CustomerUuid string
	Amount       int64
	Status       string
}

const (
	ErrInternalServer = "ERR_INTERNAL_SERVER"
	ErrInputInvalid   = "ERR_INPUT_INVALID"
	ErrOrderNotFound  = "ERR_ORDER_NOT_FOUND"
)
```

**Error type** — `internal/pkg/errors`. Every port method returns `*errors.CustomError`, never a bare `error`:

```go
type CustomError struct {
	Code    string
	Message string
}

func NewCustomError(code, message string) *CustomError { return &CustomError{Code: code, Message: message} }
```

**Inbound port** — `internal/core/port/inbound/order.go`. Give a method an input/output struct once it has more than a few parameters or a second transport:

```go
type IOrderPort interface {
	GetByUuid(ctx contexts.IContextService, orderUuid string) (*domain.OrderData, *errors.CustomError)
	Create(ctx contexts.IContextService, in *CreateOrderInput) (*domain.OrderData, *errors.CustomError)
}

type CreateOrderInput struct {
	CustomerUuid string
	Amount       int64
}
```

**Outbound ports** — `internal/core/port/outbound/repository/repository.go`, `factory.go`, and one file per gateway in `internal/core/port/outbound/`:

```go
type IOrderRepository interface {
	GetByUuid(ctx contexts.IContextService, orderUuid string) (*domain.OrderData, *errors.CustomError)
	Create(ctx contexts.IContextService, order *domain.OrderData) *errors.CustomError
}

type IRepositoryFactory interface {
	GetOrderRepository() IOrderRepository
}

type INotificationGateway interface {
	Notify(ctx contexts.IContextService, title string, fields map[string]string) *errors.CustomError
}
```

**Service** — `internal/core/service/order_service.go`. Business rules live here; it takes the factory and picks its own repositories:

```go
type OrderService struct {
	repo     repository.IOrderRepository
	notifier outbound.INotificationGateway
}

func NewOrderService(repoFactory repository.IRepositoryFactory, notifier outbound.INotificationGateway) inbound.IOrderPort {
	return &OrderService{repo: repoFactory.GetOrderRepository(), notifier: notifier}
}

func (s *OrderService) Create(ctx contexts.IContextService, in *inbound.CreateOrderInput) (*domain.OrderData, *errors.CustomError) {
	if in.Amount <= 0 {
		return nil, errors.NewCustomError(domain.ErrInputInvalid, "Amount must be positive")
	}
	order := &domain.OrderData{OrderUuid: utils.NewUuid(), CustomerUuid: in.CustomerUuid, Amount: in.Amount, Status: domain.OrderStatusPending}
	if err := s.repo.Create(ctx, order); err != nil {
		ctx.GetLogger().PrintLogErrorFormat("Failed to create order: %v", err)
		return nil, err
	}
	return order, nil
}
```

**Handler** — `internal/adapter/inbound/handler/order/`. `dto.go` holds unexported wire structs with `json` and `binding` tags; `handler.go` binds, calls ports, maps:

```go
package order_hdl

const (
	groupPath       = "/order"
	pathCreateOrder = "/create"
)

type createOrderRequest struct {
	CustomerUuid string `json:"customerID" binding:"required"`
	Amount       int64  `json:"amount" binding:"required"`
}

type IHandler interface {
	CreateOrder(c *gin.Context)
	RegisterRoutes(routeSvc routes.IRouteService)
}

type Handler struct {
	orderSvc inbound.IOrderPort
	routeSvc routes.IRouteService
}

func NewHandler(orderSvc inbound.IOrderPort, routeSvc routes.IRouteService) IHandler {
	return &Handler{orderSvc: orderSvc, routeSvc: routeSvc}
}

func (h *Handler) RegisterRoutes(routeSvc routes.IRouteService) {
	group := routeSvc.GetRouterGroup(nil, groupPath)
	group.POST(pathCreateOrder, h.CreateOrder)
}

func (h *Handler) CreateOrder(c *gin.Context) {
	ctx := h.routeSvc.GetContextService(c)

	var request createOrderRequest
	if err := h.routeSvc.ValidateRequest(ctx, &request); err != nil {
		adapterinbound.ResponseWithError(ctx, err)
		return
	}

	order, err := h.orderSvc.Create(ctx, &inbound.CreateOrderInput{
		CustomerUuid: request.CustomerUuid,
		Amount:       request.Amount,
	})
	if err != nil {
		adapterinbound.ResponseWithError(ctx, err)
		return
	}
	adapterinbound.ResponseWithSuccess(ctx, toCreateOrderResponse(order))
}
```

`ResponseWithError` in the shared `handler` package is the single place an error code becomes an HTTP status — a new code is added to its `switch`, never mapped inside a vertical. Middleware sits beside the handler as a function taking ports and returning `gin.HandlerFunc`; it answers through the same helper, then `c.Abort()`.

**Repository** — `internal/adapter/outbound/db/order.go`. It owns storage strategy (cache first, database on a miss, cache filled in the background) and converts row structs to domain structs; no business rule:

```go
type OrderRepository struct {
	pg    postgresql.IPostgreSqlDBService
	cache cache.ICacheDBService
}

func NewOrderRepository(pgSvc postgresql.IPostgreSqlDBService, cacheSvc cache.ICacheDBService) repository.IOrderRepository {
	return &OrderRepository{pg: pgSvc, cache: cacheSvc}
}

func (r *OrderRepository) GetByUuid(ctx contexts.IContextService, orderUuid string) (*domain.OrderData, *errors.CustomError) {
	orderDB, err := r.getByUuidCache(ctx, orderUuid)
	if err != nil {
		orderDB, err = r.getByUuidPostgres(ctx, orderUuid)
		if err != nil {
			return nil, err
		}
		go r.cacheOrderData(contexts.NewBackgroundContextService(ctx.GetLogger()), orderDB)
	}
	return convertOrderDataFromDB(orderDB), nil
}
```

Row struct and query keys in `db/postgresql/postgresqldb/order.go`, each key naming a file in `db/postgresql/sql/`; cache keys in `db/cache/cachedb/order.go`:

```go
const ORDER_DB_GET_QUERY_KEY = "get-order-by-order-uuid" // sql/get-order-by-order-uuid.sql

type OrderDB struct {
	OrderUuid    string `db:"order_uuid" json:"ou"`
	CustomerUuid string `db:"customer_uuid" json:"cu"`
	Amount       int64  `db:"amount" json:"a"`
	Status       string `db:"status" json:"s"`
}
```

`db/factory.go` builds every repository once and implements `IRepositoryFactory`. Multi-statement writes go through the tx manager — `RunInTransaction(ctx, func(tx ITxSession) error { ... })` — which commits on `nil`, rolls back on an error or a panic, and never leaves the adapter.

**Gateway** — `internal/adapter/outbound/notification/main.go`: `func NewGateway() outbound.INotificationGateway`. A mock implementation of the same port lives in its own sibling package and is chosen in `cmd/main.go`.

**Composition root** — `cmd/main.go`, in this order: config, drivers, repository factory, gateways, services, route service, handlers:

```go
repoFactory := outbounddb.NewRepositoryFactory(pgSvc, cacheSvc)
notifier := outboundnotification.NewGateway()

orderSvc := coreservice.NewOrderService(repoFactory, notifier)

routeSvc := inboundroutes.NewRouteService(ctx, envService)
orderHandler := inboundorder.NewHandler(orderSvc, routeSvc)
orderHandler.RegisterRoutes(routeSvc)
```

## Variations

- **Sequencing across several services.** The handler takes every port it needs and orders the calls itself; each service stays a narrow owner of its own data.
- **Two transports for one endpoint set** (HTTP and gRPC, or HTTP and a scheduler). Put the sequencing in a transport-neutral `<Vertical>MainHandler` in the handler package, taking and returning `core/port/inbound` input/output structs and `*errors.CustomError`. Each transport is then a thin shell: bind, call, map. Build one `MainHandler` in `cmd/main.go` and hand it to both.
- **Background work.** A scheduler in `adapter/inbound/scheduler` takes inbound ports like a handler, exposes `Start(ctx)`, creates a fresh background context per tick, and is started once from `cmd/main.go`.

## Adding a vertical

1. `core/domain` — the structs and any new error code.
2. `core/port/outbound/repository` — the repository interface and its factory getter; a gateway interface if an external service is involved.
3. `core/port/inbound` — the port interface and its input/output structs.
4. `core/service` — the service implementing the port.
5. `adapter/outbound/db` — row struct, query keys and `.sql` files, cache keys, the repository, the factory entry.
6. `adapter/inbound/handler/<vertical>` — `dto.go`, `handler.go`, `RegisterRoutes`; a new error code in the shared response switch.
7. `cmd/main.go` — construct and register.

## Review checklist

- No `adapter` import under `core`; no `core/service` import under `adapter`.
- No service field holding another service's port.
- No `binding` or `db` tag on a `core/domain` struct, and a `json` tag only on a value type persisted as a JSON document; no DTO or row struct crossing a port.
- No `ctx.GetGinContext()` under `core`.
- No SQL string, cache key, or HTTP status code outside its adapter.
- Every constructor returns its interface, and nothing outside `cmd/main.go` calls one.
