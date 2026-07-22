# CLAUDE.md

Projet fil rouge du **Udemy « Complete dbt Bootcamp »** : un pipeline **dbt** qui transforme des données brutes Airbnb (dans **Snowflake**) en modèles analytiques, selon une architecture en couches.

## Environnement & commandes

L'environnement Python est géré avec **uv**. dbt n'est **pas** installé en global : il vit dans le `.venv` du projet. Deux façons de lancer dbt :

- **Préfixer par `uv run`** (recommandé, aucune activation nécessaire) : `uv run dbt build`.
- **Activer le `.venv`** puis appeler `dbt` directement : `.\.venv\Scripts\activate.ps1` (le prompt affiche alors `(dbt-bootcamp)`), ensuite `dbt build`, `dbt run`, etc. sans le préfixe `uv run`.

Les commandes ci-dessous utilisent `uv run` ; retire ce préfixe si ton `.venv` est activé.

```bash
uv sync                      # après un clone : reconstruit .venv depuis uv.lock
uv run dbt debug             # vérifie la config Snowflake
uv run dbt build             # run + test de tout le DAG (commande principale)
uv run dbt run               # matérialise les modèles
uv run dbt test              # exécute les tests seuls
uv run dbt snapshot          # met à jour les snapshots SCD2
uv run dbt seed              # charge les CSV de seeds/
uv run dbt docs generate && uv run dbt docs serve
```

Cibler un modèle : `uv run dbt run -s dim_listings_cleansed` (ou `-s +mart_fullmoon_reviews` pour lui + ses parents).

- Plateforme : **Windows / PowerShell**. Bash disponible mais PowerShell est le shell primaire.
- Dépendances épinglées dans [pyproject.toml](pyproject.toml) (`dbt-core~=1.11`, `dbt-snowflake~=1.11`). Toute nouvelle dépendance : `uv add <pkg>` puis committer `pyproject.toml` + `uv.lock`.

## Architecture du projet dbt (`airbnb/`)

Configuré par [airbnb/dbt_project.yml](airbnb/dbt_project.yml). Le DAG suit 4 couches ; dbt gère l'ordre via `{{ ref() }}` / `{{ source() }}`.

| Couche | Dossier | Matérialisation | Rôle |
|--------|---------|-----------------|------|
| Sources | `models/src/_sources.yml` | — | Tables brutes `raw_listings` / `raw_hosts` / `raw_reviews` + test de *freshness* |
| Staging (`src`) | `models/src/` | `ephemeral` | Renommage/sélection simple, pas d'objet créé en base |
| Dimensions (`dim`) | `models/dim/` | `table` | Nettoyage (prix `$`→number, `minimum_nights` 0→1) + jointures |
| Faits (`fct`) | `models/fct/` | `incremental` | `fct_reviews` : chargement incrémental sur `review_date`, `on_schema_change='fail'` |
| Mart | `models/mart/` | `table` | `mart_fullmoon_reviews` : croise reviews × seed de pleines lunes |

Flux : `src_* → dim_* / fct_* → dim_listings_w_hosts / mart_fullmoon_reviews`.

Les défauts de matérialisation sont définis par dossier dans `dbt_project.yml` ; un modèle peut les surcharger via `{{ config(materialized=...) }}` en tête de fichier.

## Autres briques dbt illustrées

- **Organisation des YAML** — un `.yml` par couche, co-localisé dans son dossier : `models/src/_sources.yml` (sources) + `_src__models.yml`, `models/dim/_dim__models.yml`, `models/fct/_fct__models.yml`, `models/mart/_mart__models.yml`. dbt fusionne tous les `.yml` sous `models/` ; le découpage est purement organisationnel.
- **Tests** — [airbnb/models/dim/_dim__models.yml](airbnb/models/dim/_dim__models.yml) : tests génériques natifs (`unique`, `not_null`, `relationships`, `accepted_values`) + custom.
  - Tests génériques custom dans `tests/generic/` (`positive_values`, `minimum_row_count`).
  - Tests singuliers (SQL) dans `tests/` (ex. `consistent_created_at.sql`).
  - `+store_failures: true` : les lignes en échec sont persistées dans le schéma `test_failures`.
- **Unit tests** — `models/mart/unit_test.yml` : données mockées in/out sur `mart_fullmoon_reviews`.
- **Contrats** — `dim_hosts_cleansed` a `contract.enforced: true` (types de colonnes vérifiés à la matérialisation).
- **Snapshots** — `snapshots/*.yml` : SCD Type 2 sur listings/hosts (stratégie `timestamp`).
- **Macros** — `macros/` : `no_empty_strings`, `select_positive_values`.
- **Seeds** — `seeds/seed_full_moon_dates.csv`.

## Conventions

- Préfixe = couche (`src_`, `dim_`, `fct_`, `mart_`). Respecter ce nommage pour tout nouveau modèle.
- Un modèle référence toujours un autre via `ref()`, jamais un nom de table en dur ; les tables brutes via `source()`.
- Cible Snowflake : base `AIRBNB`, schéma `DEV`, warehouse `COMPUTE_WH`, auth **key-pair**.

## ⚠️ Sécurité — credentials

`airbnb/profiles.yml` contient une **clé privée + passphrase**. Il est listé dans `.gitignore` **mais reste suivi par git** (déjà committé) — le `.gitignore` n'exclut pas un fichier déjà tracké.

- Ne jamais committer de credentials. En pratique, `profiles.yml` devrait vivre dans `~/.dbt/`, pas dans le repo.
- Pour désuivre : `git rm --cached airbnb/profiles.yml` (la clé reste néanmoins dans l'historique → à régénérer côté Snowflake).

## Ressources

- Guide d'installation détaillé (uv, Snowflake, key-pair, workflow git d'équipe) : [_course_resources/notes/guide_dbt_snowflake_uv_windows.md](_course_resources/notes/guide_dbt_snowflake_uv_windows.md).
