# AGENTS - GameNet iOS App

## Visão Geral

GameNet é um aplicativo iOS desenvolvido em SwiftUI para gerenciar a biblioteca de jogos dos usuários. O projeto segue os princípios de **Clean Architecture** com separação clara de responsabilidades entre as camadas.

## Arquitetura

O projeto utiliza **Clean Architecture** com as seguintes camadas:

### 1. Domain Layer (Camada de Domínio)
**Localização:** `GameNet/Domain/`

Responsável por:
- Entidades de domínio (Entities)
- Erros compartilhados
- Regras de negócio puras

**Estrutura:**
```
Domain/
├── Entities/
│   └── Login/
│       └── Login.swift
└── Shared/
    └── Errors/
        └── APIError.swift
```

**Características:**
- Não depende de nenhuma outra camada
- Contém apenas lógica de negócio
- Entidades representam os conceitos centrais da aplicação

### 2. Data Layer (Camada de Dados)
**Localização:** `GameNet/DataProviders/`

Responsável por:
- Implementação de repositórios
- Fontes de dados (DataSources)
- Acesso a APIs e persistência

**Estrutura:**
```
DataProviders/
├── DataSources/
│   ├── Dashboard/
│   ├── Game/
│   ├── GameplaySession/
│   ├── List/
│   ├── Login/
│   └── Platform/
└── Repositories/
    ├── Dashboard/
    ├── Game/
    ├── GameplaySession/
    ├── List/
    ├── Login/
    └── Platform/
```

**Padrões Implementados:**

#### Repository Pattern
- **Protocolo:** `*RepositoryProtocol` (ex: `LoginRepositoryProtocol`)
- **Implementação:** `*Repository` (ex: `LoginRepository`)
- **Responsabilidade:** Abstrai a fonte de dados e fornece uma interface unificada para a camada de apresentação

#### DataSource Pattern
- **Protocolo:** `*DataSourceProtocol` (ex: `LoginDataSourceProtocol`)
- **Implementação:** `*DataSource` (ex: `LoginDataSource`)
- **Responsabilidade:** Implementa o acesso direto a APIs, cache ou banco de dados

**Fluxo de Dados:**
```
ViewModel → Repository → DataSource → Network/Storage
```

### 3. Presentation Layer (Camada de Apresentação)
**Localização:** `GameNet/Presentation/`

Responsável por:
- Views (SwiftUI)
- ViewModels (MVVM)
- Estados e modelos de apresentação
- Navegação (Routers)

**Estrutura:**
```
Presentation/
├── Components/          # Componentes reutilizáveis
├── Extensions/          # Extensões de tipos Swift/SwiftUI
├── Features/            # Features organizadas por módulo
│   ├── Dashboard/
│   ├── Games/
│   ├── Lists/
│   ├── Login/
│   ├── Platforms/
│   └── Home/
└── Styles/              # Estilos customizados
```

**Padrão MVVM:**
- **View:** SwiftUI Views (`*View.swift`)
- **ViewModel:** Classes `ObservableObject` com `@Published` properties (`*ViewModel.swift`)
- **Model:** Estados e modelos de apresentação (`*State.swift`, `*Model.swift`)

**Estrutura de uma Feature:**
```
FeatureName/
├── Model/               # Estados e modelos de apresentação
├── Router/              # Navegação (Factory de Views)
├── View/                # SwiftUI Views
└── ViewModel/           # ViewModels com lógica de apresentação
```

## Dependency Injection

O projeto utiliza **Factory** para injeção de dependências.

**Localização:** `GameNet/DI/`

**Containers:**
- `DataSourceContainer`: Registra todos os DataSources
- `RepositoryContainer`: Registra todos os Repositories

**Uso:**
```swift
@Injected(RepositoryContainer.loginRepository) private var repository
```

**Benefícios:**
- Facilita testes (mock de dependências)
- Baixo acoplamento
- Inversão de controle

## Features Principais

### 1. Login
**Caminho:** `Presentation/Features/Login/`

**Componentes:**
- `LoginView`: Interface de login
- `LoginViewModel`: Gerencia estado e lógica de autenticação
- `LoginState`: Estados possíveis (idle, loading, success, error)
- `LoginRouter`: Factory para criação de views relacionadas

**Fluxo:**
1. Usuário insere credenciais
2. ViewModel chama `LoginRepository`
3. Repository chama `LoginDataSource`
4. DataSource faz requisição à API
5. Token é salvo no Keychain
6. Estado é atualizado na ViewModel

### 2. Dashboard
**Caminho:** `Presentation/Features/Dashboard/`

**Componentes:**
- `DashboardView`: Tela principal com estatísticas
- `DashboardViewModel`: Gerencia dados do dashboard
- `DashboardState`: Estados de carregamento
- Sub-views: `GameCoverView`, `GameplayChartView`, `FinishedByYearTimelineView`

**Funcionalidades:**
- Estatísticas de jogos (jogando, finalizados, comprados)
- Gráficos de gameplay por ano
- Timeline de jogos finalizados por ano
- Navegação para detalhes de jogos e sessões

### 3. Games
**Caminho:** `Presentation/Features/Games/`

**Componentes:**
- `GamesView`: Lista de jogos com paginação
- `GamesViewModel`: Gerencia lista paginada e busca
- `GameDetailView`: Detalhes de um jogo específico
- `GameEditView`: Edição/criação de jogos
- `GameRouter`: Navegação entre views de jogos

**Funcionalidades:**
- Listagem paginada de jogos
- Busca de jogos
- Detalhes com sessões de gameplay
- Edição de informações do jogo

### 4. Platforms
**Caminho:** `Presentation/Features/Platforms/`

**Componentes:**
- `PlatformsView`: Lista de plataformas
- `PlatformsViewModel`: Gerencia lista de plataformas
- `EditPlatformView`: Criação/edição de plataformas
- `PlatformRouter`: Navegação

**Funcionalidades:**
- Listagem de plataformas do usuário
- Criação e edição de plataformas
- Cache de dados

### 5. Lists
**Caminho:** `Presentation/Features/Lists/`

**Componentes:**
- `ListsView`: Lista de listas personalizadas
- `ListsViewModel`: Gerencia listas
- `ListGamesView`: Jogos de uma lista específica
- `EditListView`: Criação/edição de listas
- `ListRouter`: Navegação

**Funcionalidades:**
- Criação de listas personalizadas (ex: "Melhores jogos", "Próximos a comprar")
- Adição de jogos às listas
- Visualização de jogos por lista
- Timeline de jogos finalizados/comprados por ano

### 6. Home
**Caminho:** `Presentation/Features/Home/`

**Componentes:**
- `HomeView`: Tela inicial após login
- `HomeViewModel`: Gerencia estado da home

## Componentes Reutilizáveis

**Localização:** `Presentation/Components/`

- `CurrencyTextField`: Campo de texto formatado para moeda
- Componentes de UI customizados

## Extensions

**Localização:** `Presentation/Extensions/`

- `Binding+Extensions`: Extensões para Binding
- `Color`: Cores customizadas
- `Date+Extensions`: Formatação de datas
- `Font`: Fontes customizadas
- `Number+Extensions`: Formatação de números
- `View+Extensions`: Modificadores e helpers para Views

## Navegação (Routers)

Cada feature possui um Router que funciona como Factory para criação de views:

**Exemplo:**
```swift
// LoginRouter.swift
static func makeHomeView() -> some View
static func makeLoginView() -> some View
```

**Benefícios:**
- Centraliza criação de views
- Facilita injeção de dependências
- Melhora testabilidade

## Estados e Gerenciamento de Estado

Cada ViewModel utiliza um enum de estado para gerenciar diferentes fases:

**Padrão comum:**
```swift
enum FeatureState {
    case idle
    case loading
    case success(Data)
    case error(String)
}
```

**Uso:**
- `@Published var state: FeatureState = .idle`
- Views reagem às mudanças de estado
- Combine é usado para observar mudanças

## Testes

**Localização:** `GameNetTests/`

**Estrutura de Testes:**
- Testes de DataSources
- Testes de Repositories
- Testes de ViewModels
- Mocks para isolamento de dependências

**Mocks:**
- `Mock*DataSource`: Implementações mockadas de DataSources
- `Mock*Repository`: Implementações mockadas de Repositories

## Configuração

**Localização:** `GameNet/Config/`

- Configurações da aplicação
- Constantes globais (definidas em `GameNetApp`)

## Recursos

**Localização:** `GameNet/Resources/`

- Assets (imagens, cores)
- Configurações (GoogleService-Info.plist)
- Config.xcconfig

## Princípios de Clean Architecture Aplicados

1. **Independência de Frameworks:** A lógica de negócio não depende de frameworks externos
2. **Testabilidade:** Camadas podem ser testadas independentemente
3. **Independência de UI:** A lógica não depende da interface
4. **Independência de Banco de Dados:** A lógica não depende de persistência específica
5. **Independência de Agentes Externos:** A lógica não conhece detalhes de APIs externas

## Fluxo de Dados Típico

```
User Action (View)
    ↓
ViewModel.processAction()
    ↓
Repository.fetchData()
    ↓
DataSource.getData() → Network/Storage
    ↓
DataSource returns Data
    ↓
Repository returns Domain Entity
    ↓
ViewModel updates @Published state
    ↓
View reacts to state change (SwiftUI)
```

## Convenções de Nomenclatura

- **Views:** `*View.swift` (ex: `LoginView.swift`)
- **ViewModels:** `*ViewModel.swift` (ex: `LoginViewModel.swift`)
- **Repositories:** `*Repository.swift` (ex: `LoginRepository.swift`)
- **DataSources:** `*DataSource.swift` (ex: `LoginDataSource.swift`)
- **Protocols:** `*Protocol` (ex: `LoginRepositoryProtocol`)
- **States:** `*State.swift` (ex: `LoginState.swift`)
- **Routers:** `*Router.swift` (ex: `LoginRouter.swift`)

## Dependências Externas

- **Factory:** Dependency Injection
- **GameNet_Network:** Camada de rede (módulo separado)
- **GameNet_Keychain:** Gerenciamento de Keychain (módulo separado)
- **Combine:** Reactive programming
- **SwiftUI:** Framework de UI

## Observações Importantes

⚠️ **Ignorar:**
- Features de Server-Driven UI
- Features do Apple Watch
- WatchConnectivity

✅ **Focar:**
- Clean Architecture
- Separação de camadas (Domain, Data, Presentation)
- Padrões Repository e DataSource
- MVVM na camada de apresentação
- Dependency Injection com Factory
