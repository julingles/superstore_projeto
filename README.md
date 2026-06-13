# 🛍️ Sales Superstore - Data Warehouse & ETL

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-blue?logo=postgresql)
![License](https://img.shields.io/badge/License-MIT-green)
![Status](https://img.shields.io/badge/Status-Production-brightgreen)

> Projeto de modelagem dimensional (Star Schema) para análise de vendas, com pipeline ETL completo para PostgreSQL.

## 📋 Índice

- [Visão Geral](#visão-geral)
- [Arquitetura/Modelo de Dados](#arquitetura)

---

## 🎯 Visão Geral

Este projeto implementa um **ETL em SQL** para a base de dados Sales Superstore, transformando dados brutos de vendas em um modelo dimensional otimizado para consultas analíticas.

| Item | Descrição |
|------|-----------|
| **Origem** | Arquivos Excel (3 abas: orders, people, returns) |
| **Destino** | PostgreSQL |
| **Arquitetura** | Star Schema (Esquema Estrela) |
| **Linhas processadas** | ~10.000+ registros de vendas |

### Objetivos

- ✅ Padronizar e limpar dados inconsistentes
- ✅ Construir modelo dimensional para análises rápidas
- ✅ Garantir integridade referencial
- ✅ Permitir consultas de BI e dashboard

---

## 🏗️ Arquitetura
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                     │
│   📊 Excel (.xlsx)                                                                  │
│   ┌─────────┐ ┌─────────┐ ┌─────────┐                                              │
│   │ Orders  │ │ People  │ │ Returns │                                              │
│   │   aba   │ │   aba   │ │   aba   │                                              │
│   └────┬────┘ └────┬────┘ └────┬────┘                                              │
│        │           │           │                                                    │
│        ▼           ▼           ▼                                                    │
│   ┌─────────────────────────────────┐                                              │
│   │         📁 3 CSVs               │                                              │
│   │   orders.csv  people.csv  returns.csv  │                                       │
│   └────────────────┬────────────────┘                                              │
│                    │                                                               │
│                    ▼                                                               │
│   ┌─────────────────────────────────────────────────┐                             │
│   │                 🗄️ STAGING                      │                             │
│   │         (Tabelas temporárias no PostgreSQL)      │                             │
│   │    stage_orders │ stage_people │ stage_returns   │                             │
│   └────────────────────────┬────────────────────────┘                             │
│                            │                                                        │
│                            ▼                                                        │
│   ┌─────────────────────────────────────────────────┐                             │
│   │                 ⚙️ TRATAMENTO                    │                             │
│   │  ┌──────────┐ ┌──────────┐ ┌──────────────────┐ │                             │
│   │  │ 🧹 TRIM  │ │ 📅 parse │ │ 🎯 padronização  │ │                             │
│   │  │  espaços │ │  datas   │ │     regiões      │ │                             │
│   │  └──────────┘ └──────────┘ └──────────────────┘ │                             │
│   │  ┌──────────┐ ┌──────────┐ ┌──────────────────┐ │                             │
│   │  │ 🔄 vírgula│ │ 📝 INITCAP│ │ 🔗 JOINs        │ │                             │
│   │  │  para .  │ │  nomes   │ │   relacionamentos│ │                             │
│   │  └──────────┘ └──────────┘ └──────────────────┘ │                             │
│   └────────────────────────┬────────────────────────┘                             │
│                            │                                                        │
│                            ▼                                                        │
│   ┌─────────────────────────────────────────────────┐                             │
│   │            🏛️ TABELAS ANALÍTICAS                 │                             │
│   │                (Star Schema)                     │                             │
│   │                                                   │                             │
│   │   ┌──────────┐ ┌──────────┐ ┌──────────────────┐ │                             │
│   │   │dim_cust. │ │dim_prod. │ │  dim_address     │ │                             │
│   │   └────┬─────┘ └────┬─────┘ └───────┬──────────┘ │                             │
│   │        │            │               │            │                             │
│   │        └────────────┼───────────────┘            │                             │
│   │                     ▼                            │                             │
│   │            ┌───────────────┐                     │                             │
│   │            │  fact_sales   │                     │                             │
│   │            │   (Fato)      │                     │                             │
│   │            └───────────────┘                     │                             │
│   │                                                   │                             │
│   │   ┌──────────┐ ┌──────────┐ ┌──────────────────┐ │                             │
│   │   │dim_order │ │dim_people│ │  dim_returns     │ │                             │
│   │   └──────────┘ └──────────┘ └──────────────────┘ │                             │
│   └────────────────────────┬────────────────────────┘                             │
│                            │                                                        │
│                            ▼                                                        │
│   ┌─────────────────────────────────────────────────┐                             │
│   │              📊 POWER BI                         │                             │
│   │         Dashboards Interativos                   │                             │
│   │                                                   │                             │
│   │   📈 Vendas por região    🥧 Devoluções por mês  │                             │
│   │   📊 Top 10 clientes      📉 Margem de lucro     │                             │
│   │   🎯 KPIs de performance  📅 Tendências temporais│                             │
│   └─────────────────────────────────────────────────┘                             │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘

<img width="1130" height="572" alt="modelo de dados" src="https://github.com/user-attachments/assets/517b8dcd-ffe3-4aa2-a0b3-a2703b1a3f01" />
