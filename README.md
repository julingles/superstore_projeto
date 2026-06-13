# 🛍️ Sales Superstore - Data Warehouse & ETL

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-blue?logo=postgresql)
![License](https://img.shields.io/badge/License-MIT-green)
![Status](https://img.shields.io/badge/Status-Production-brightgreen)

> Projeto de modelagem dimensional (Star Schema) para análise de vendas, com pipeline ETL completo para PostgreSQL.

## 📋 Índice

- [Visão Geral](#visão-geral)
- [Arquitetura](#arquitetura)
- [Modelo de Dados](#modelo-de-dados)

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
<img width="1693" height="423" alt="image" src="https://github.com/user-attachments/assets/680d3d2e-553d-4042-a6f9-7642f7d8b65c" />


## 📋 Modelo de Dados
<img width="1130" height="572" alt="modelo de dados" src="https://github.com/user-attachments/assets/517b8dcd-ffe3-4aa2-a0b3-a2703b1a3f01" />
