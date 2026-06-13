# 🛍️ Sales Superstore - Data Warehouse & ETL

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-blue?logo=postgresql)
![License](https://img.shields.io/badge/License-MIT-green)
![Status](https://img.shields.io/badge/Status-Production-brightgreen)

> Projeto de modelagem dimensional (Star Schema) para análise de vendas, com pipeline ETL completo para PostgreSQL.

## 📋 Índice

- [Visão Geral](#visão-geral)
- [Arquitetura](#arquitetura)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Pré-requisitos](#pré-requisitos)
- [Configuração e Execução](#configuração-e-execução)
- [Modelo de Dados](#modelo-de-dados)
- [Funções Auxiliares](#funções-auxiliares)
- [Consultas Analíticas](#consultas-analíticas)
- [Troubleshooting](#troubleshooting)
- [Contribuição](#contribuição)
- [Licença](#licença)

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
