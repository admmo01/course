# Installer dbt-core avec le connecteur Snowflake 1.11.2 avec uv (Windows)




## 1. Installer uv sur windows 

irm https://astral.sh/uv/install.ps1 | iex

uv --version

## 2. Installer Python sur windows 

uv python install 3.13

python --version

## 3. Installer dbt-core exemple de version 1.11.2

uv tool install dbt-core==1.11.2

## 4. Créer un projet uv


mkdir analytics-dbt
cd analytics-dbt
uv init

```
- Initialise un projet uv
- Crée `pyproject.toml` et `uv.lock`
- uv gère automatiquement l’environnement virtuel

```

## 5. Installer adapter dbt Snowflake 1.11.1 

uv add dbt-snowflake==1.11.1

```
- Installe automatiquement :
  - `dbt-core==1.11.2`
  - `dbt-snowflake==1.11.1`
- Dépendances verrouillées dans `uv.lock`

```

## 6. Vérifier l’installation

uv run dbt --version


Résultat attendu :

```
Core:
  - installed: 1.11.2
Plugins:
  - snowflake: 1.11.2
```

⚠️ Toujours utiliser `uv run dbt`, sinon Snowflake ne sera pas détecté. ou bien activer l'environnement virtuel .\.venv\Scripts\activate.ps1

---

## 7. Initialiser le projet dbt
 
uv run dbt init mon_projet_dbt
cd mon_projet_dbt
uv run dbt debug

```
- Crée la structure dbt
- Vérifie la configuration Snowflake

uv run dbt init … doit être exécuté dans le dossier du projet UV
(celui où se trouvent pyproject.toml et éventuellement uv.lock).

✅ Pourquoi c’est obligatoire

uv run :

cherche le projet UV courant

charge les dépendances déclarées dans pyproject.toml

dbt :

est installé dans cet environnement UV

n’est pas global

👉 Si tu exécutes la commande ailleurs, dbt ne sera pas trouvé ou l’adapter Snowflake ne sera pas chargé.
```

## 7. Configurer Snowflake

Fichier : profiles.yml


Exemple minimal :

```yaml
mon_projet_dbt:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: <account>
      user: <user>
      password: <password>
      role: <role>
      database: <database>
      warehouse: <warehouse>
      schema: <schema>
```

---

## 8. Utiliser dbt

Toujours avec uv :

```powershell
uv run dbt run
uv run dbt test
uv run dbt docs generate
uv run dbt docs serve
```
## 8. uninstall dbt

uv tool uninstall dbt-core

supprimer le projet uv = supprimer le dossier du projet : 

rmdir -R -Force <nom_dossier>

## 8. uninstall uv

uv cache clean
rm -r "$(uv python dir)"
rm -r "$(uv tool dir)"

rm $HOME\.local\bin\uv.exe
rm $HOME\.local\bin\uvx.exe
rm $HOME\.local\bin\uvw.exe



# Installer dbt-core avec le connecteur Snowflake 1.11.2 avec PIP (Windows)

python -m pip --version

python -m venv env

.\env\Scripts\activate

python -m pip install --upgrade pip

pip install "dbt-core==1.11.2" "dbt-snowflake==1.11.1"
   
dbt --version

dbt init jaffle_shop

cd .\jaffle_shop\

dbt debug


