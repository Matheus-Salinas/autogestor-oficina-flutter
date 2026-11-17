# AutoGestor - Sistema de Controle de Oficina Mecanica

Aplicacao multiplataforma desenvolvida em **Flutter** e **Dart** como Projeto Final (P2), integrando autenticacao de usuarios, gerenciamento de rotas, validacao de formularios e persistencia de dados em nuvem com **Supabase (PostgreSQL)**.

---

## 1. Descricao do Aplicativo

O **AutoGestor** e um sistema voltado para oficinas mecanicas automotivas que resolve o problema de organizacao e acompanhamento de Ordens de Servico (OS). Por meio da aplicacao, mecanicos e gestores podem criar uma conta individual, acessar o painel da oficina de forma segura e gerenciar todo o ciclo de manutencao dos veiculos atendidos (desde o orcamento inicial ate a conclusao do servico).

---

## 2. Funcionalidades Principais

### Autenticacao e Seguranca
- **Cadastro de Usuario:** Criacao de conta com e-mail, senha e confirmacao de senha validada.
- **Login de Usuario:** Autenticacao segura via e-mail e senha com manutencao de sessao ativa.
- **Logout:** Encerramento seguro da sessao com redirecionamento automatico para a tela de login.
- **Protecao de Rotas/Telas:** Bloqueio de acesso a tela principal (`HomeScreen`) para usuarios nao autenticados.
- **Tratamento de Erros:** Traducao automatica de erros do servidor para mensagens claras em portugues (credenciais invalidas, e-mail ja cadastrado, senha curta ou formato de e-mail invalido).

### CRUD Completo de Ordens de Servico
- **Criar (Create):** Formulario dedicado para registrar novas manutencoes contendo modelo do veiculo, placa, descricao do servico/pecas, valor do orcamento e status inicial.
- **Ler (Read):** Listagem atualizada das ordens de servico cadastradas pelo usuario logado, acompanhada de um painel superior que calcula automaticamente o total de veiculos atendidos e a soma financeira dos orcamentos.
- **Atualizar (Update):** Edicao completa de qualquer ordem de servico existente e alteracao do status de andamento (*Pendente*, *Em Andamento* ou *Concluido*) com identificacao visual por cores.
- **Deletar (Delete):** Exclusao de registros mediante confirmacao em caixa de dialogo (`AlertDialog`) para prevenir remocoes acidentais.

---

## 3. Tecnologias Utilizadas

- **Flutter:** Framework para construcao da interface multiplataforma (Mobile e Web) utilizando Material Design 3.
- **Dart:** Linguagem de programacao utilizada para toda a logica de negocios, modelos e controle de estado.
- **Supabase (`supabase_flutter`):** Plataforma Backend-as-a-Service utilizada para:
  - **Supabase Auth:** Servico de autenticacao de usuarios via e-mail e senha com tokens JWT.
  - **Supabase Database (PostgreSQL):** Banco de dados relacional em nuvem para armazenamento persistente das ordens de servico.
- **Git / GitHub:** Controle de versao e hospedagem do codigo-fonte.

---

## 4. Arquitetura e Estrutura do Projeto

O codigo-fonte foi organizado dentro do diretorio `/lib` seguindo o principio de separacao de responsabilidades (modelos, servicos de dados/autenticacao, componentes visuais e telas):

```text
/lib
 ├── main.dart                   # Ponto de entrada, inicializacao do Supabase e rotas nomeadas
 ├── /models
 │    └── manutencao_model.dart  # Classe de modelo da Ordem de Servico (conversao fromMap e toMap)
 ├── /services
 │    ├── auth_service.dart      # Logica de login, cadastro, logout e traducao de erros
 │    └── database_service.dart  # Operacoes de CRUD (Select, Insert, Update, Delete) no Supabase
 ├── /widgets
 │    ├── custom_text_field.dart # Componente reutilizavel para campos de texto com validacao
 │    └── manutencao_card.dart   # Componente visual de cartao para exibir cada Ordem de Servico
 └── /screens
      ├── login_screen.dart      # Tela de login com validacao de formulario
      ├── register_screen.dart   # Tela de cadastro de novos usuarios
      ├── home_screen.dart       # Tela principal protegida com painel financeiro e listagem
      └── form_screen.dart       # Tela de formulario para criacao e edicao de registros
```

---

## 5. Descricao da Autenticacao e da Base de Dados

### Funcionamento da Autenticacao
A autenticacao e gerenciada pela classe `AuthService` (`lib/services/auth_service.dart`), que se comunica diretamente com o **Supabase Auth**:
1. No cadastro (`signUp`), o Supabase registra as credenciais criptografadas na tabela interna `auth.users` e gera um identificador unico (`UUID`) para o usuario.
2. No login (`signInWithPassword`), o Supabase valida as credenciais e retorna uma sessao contendo um token JWT.
3. Na abertura do aplicativo (`main.dart`) e ao carregar a `HomeScreen`, o sistema verifica a propriedade `currentSession` / `currentUser`. Caso nao exista sessao valida, o acesso as telas internas e bloqueado e o usuario e redirecionado para a rota `/login`.

### Estrutura da Base de Dados
Os dados sao armazenados na tabela relacional `public.manutencoes` no PostgreSQL do Supabase:

| Coluna | Tipo | Obrigatorio | Descricao |
| :--- | :--- | :--- | :--- |
| `id` | `bigint` (PK) | Sim | Identificador unico gerado automaticamente pelo banco |
| `user_id` | `uuid` (FK) | Sim | ID do usuario autenticado (`auth.users`) proprietario do registro |
| `veiculo` | `text` | Sim | Marca e modelo do veiculo em manutencao |
| `placa` | `text` | Sim | Placa de identificacao do veiculo |
| `servico` | `text` | Sim | Descricao detalhada do servico ou pecas substituidas |
| `valor` | `numeric` | Sim | Valor orcado para a Ordem de Servico |
| `status` | `text` | Sim | Situacao atual (`Pendente`, `Em Andamento` ou `Concluido`) |
| `created_at` | `timestamptz` | Sim | Data e hora de criacao do registro |

A tabela utiliza **Row Level Security (RLS)** ativado, garantindo no nivel do banco de dados que cada usuario autenticado (`auth.uid() = user_id`) possa visualizar, inserir, editar ou remover apenas os seus proprios registros.

---

## 6. Instrucoes para Executar o Projeto

### Pre-requisitos
- Flutter SDK instalado e configurado na maquina.
- Conta gratuita no [Supabase](https://supabase.com/).
- Navegador Google Chrome (para execucao Web) ou Emulador Android / Dispositivo fisico.

### Passo 1: Configurar o Banco de Dados no Supabase
1. Crie um novo projeto no painel do Supabase.
2. No menu lateral, acesse **Authentication -> Providers -> Email**, desative a opcao **Confirm email** e clique em **Save**.
3. Acesse o menu **SQL Editor**, clique em **New query**, cole o script abaixo e clique em **Run**:

```sql
create table public.manutencoes (
  id bigint generated by default as identity primary key,
  user_id uuid references auth.users not null,
  veiculo text not null,
  placa text not null,
  servico text not null,
  valor numeric not null,
  status text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.manutencoes enable row level security;

create policy "Usuarios gerenciam suas proprias manutencoes"
on public.manutencoes
for all
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);
```

### Passo 2: Clonar e Configurar o Projeto Flutter
1. Clone este repositorio e acesse a pasta do projeto:
```bash
git clone <URL_DO_SEU_REPOSITORIO_GIT>
cd oficina_app
```

2. Instale os pacotes e dependencias do Flutter:
```bash
flutter pub get
```

3. Abra o arquivo `lib/main.dart` e substitua os campos `url` e `anonKey` pelas credenciais do seu projeto Supabase (encontradas em **Project Settings -> API** no painel do Supabase):
```dart
await Supabase.initialize(
  url: 'SUA_PROJECT_URL_DO_SUPABASE',
  anonKey: 'SUA_ANON_PUBLIC_KEY_DO_SUPABASE',
);
```

### Passo 3: Executar a Aplicacao
Para iniciar o aplicativo no navegador Google Chrome:
```bash
flutter run -d chrome
```
Ou para executar no emulador Android conectado:
```bash
flutter run
```