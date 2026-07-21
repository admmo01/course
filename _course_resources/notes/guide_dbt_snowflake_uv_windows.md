# Installer dbt-core avec le connecteur Snowflake avec uv (Windows)

## 1. Installer uv sur Windows

```powershell
irm https://astral.sh/uv/install.ps1 | iex

uv --version
```

## 2. Installer Python sur Windows

```powershell
uv python install 3.13 --default --preview

python --version
```

Le flag `--default` expose `python.exe` et `python3.exe` sur le PATH (via le répertoire bin de uv).

## ⚠️ Étape à éviter : installer dbt-core en global

```powershell
# NE PAS FAIRE
uv tool install dbt-core==1.11.2
```

**Remarque : cette étape ne sert à rien dans ce workflow.** Elle installe un dbt global dans un environnement isolé, **sans l'adapter Snowflake**. Or tout le reste du guide passe par `uv run dbt`, qui utilise l'environnement du **projet** (celui rempli par `uv add` à l'étape 4), jamais le tool global. Ce dbt global ne serait donc jamais utilisé — et si on l'appelait directement (`dbt` hors projet), il échouerait faute d'adapter Snowflake.

Si elle a été exécutée par erreur : `uv tool uninstall dbt-core`.

## 3. Créer un projet uv

```powershell
mkdir analytics-dbt
cd analytics-dbt
uv init
```

- Initialise un projet uv
- Crée `pyproject.toml` et `uv.lock`
- uv gère automatiquement l'environnement virtuel (`.venv`)

## 4. Installer dbt-core et l'adapter dbt Snowflake

```powershell
uv add dbt-core==1.11.2 dbt-snowflake==1.11.1
```

- Les deux versions sont pinnées explicitement dans `pyproject.toml`
- Dépendances verrouillées dans `uv.lock`

## 5. Vérifier l'installation

```powershell
uv run dbt --version
```

Résultat attendu :

```
Core:
  - installed: 1.11.2
Plugins:
  - snowflake: 1.11.1
```

⚠️ Toujours utiliser `uv run dbt`, sinon dbt et l'adapter Snowflake ne seront pas détectés. Alternative : activer l'environnement virtuel avec `.\.venv\Scripts\activate.ps1`, puis utiliser `dbt` directement.

## 6. Initialiser le projet dbt

```powershell
uv run dbt init mon_projet_dbt
cd mon_projet_dbt
uv run dbt debug
```

- Crée la structure dbt
- Vérifie la configuration Snowflake

⚠️ `uv run dbt init …` doit être exécuté dans le dossier du projet uv (celui où se trouvent `pyproject.toml` et `uv.lock`), ou dans un de ses sous-dossiers.

**Pourquoi c'est obligatoire :**

`uv run` :
- cherche le projet uv courant (en remontant les dossiers)
- charge les dépendances déclarées dans `pyproject.toml`

dbt :
- est installé dans cet environnement uv
- n'est pas global

👉 Si la commande est exécutée ailleurs, dbt ne sera pas trouvé ou l'adapter Snowflake ne sera pas chargé.

## 7. Configurer Snowflake

Fichier : `C:\Users\<vous>\.dbt\profiles.yml`

⚠️ `dbt init` crée ce fichier dans le dossier `.dbt` du profil utilisateur, **pas dans le projet**. C'est l'oubli classique qui fait échouer `dbt debug`.

Exemple minimal (authentification par mot de passe) :

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

⚠️ Snowflake impose progressivement le MFA : l'authentification par mot de passe seul risque d'échouer sur un compte d'entreprise. Alternatives :

**SSO (navigateur externe) :**

```yaml
      authenticator: externalbrowser
      # supprimer la ligne password
```

**Key-pair (compte de service) :**

```yaml
      private_key_path: C:\Users\<vous>\.ssh\snowflake_key.p8
      # supprimer la ligne password
```

## 8. Utiliser dbt

Toujours avec uv :

```powershell
uv run dbt run
uv run dbt test
uv run dbt docs generate
uv run dbt docs serve
```

## 9. Utiliser uv dans un projet git existant

### Cas 1 — Le projet n'a pas encore de `pyproject.toml`

Dans le dossier cloné :

```powershell
cd mon-projet
uv init --bare
```

`--bare` crée uniquement le `pyproject.toml`, sans les fichiers d'exemple (`main.py`, README) que `uv init` génère.

Puis ajouter les dépendances :

```powershell
uv add dbt-core==1.11.2 dbt-snowflake==1.11.1
```

Si le projet a déjà un `requirements.txt`, l'importer directement :

```powershell
uv add -r requirements.txt 
```
uv pip install -r requirements.txt (installation pure, sans créer de fichiers), pour ne pas introduire un pyproject.toml parallèle au fichier de l'équipe.

La règle mnémotechnique : uv add modifie le projet, uv pip install remplit juste le venv. Vous choisissez selon que vous avez ou non autorité pour changer le format du repo.

### Cas 2 — Le projet a déjà un `pyproject.toml` et un `uv.lock`

Une seule commande :

```powershell
uv sync
```

uv crée le `.venv`, installe la bonne version de Python si nécessaire, et installe toutes les dépendances verrouillées dans `uv.lock`.

👉 **Aucune installation manuelle de dbt ou de l'adapter Snowflake n'est nécessaire** : le `uv add` initial n'est fait qu'une seule fois, par une seule personne, puis versionné. Tous les autres collaborateurs font simplement `uv sync` après le clone.

### Règles git

```gitignore
# .gitignore
.venv/
```

- **`.venv/` ne se commit jamais** — il est reconstruit par `uv sync`
- **`pyproject.toml` et `uv.lock` se committent toujours** — le lock garantit que toute l'équipe (et la CI) a exactement les mêmes versions
- **`profiles.yml` reste local** (`C:\Users\<vous>\.dbt\`) — il contient les credentials Snowflake, il ne va jamais dans le repo ; chaque collaborateur crée le sien

### Workflow d'équipe

```powershell
git clone <repo>
cd <repo>
uv sync          # environnement complet reconstruit
uv run dbt debug # tout fonctionne
```

Quand quelqu'un ajoute une dépendance avec `uv add`, il committe les deux fichiers modifiés (`pyproject.toml` + `uv.lock`) ; les autres font `git pull` puis `uv sync`.

## 10. Désinstallation

### Supprimer le projet uv

Supprimer le dossier du projet suffit (l'environnement `.venv` est dedans) :

```powershell
rmdir -R -Force <nom_dossier>
```

### Désinstaller uv complètement

```powershell
uv cache clean
rm -r "$(uv python dir)"
rm -r "$(uv tool dir)"

rm $HOME\.local\bin\uv.exe
rm $HOME\.local\bin\uvx.exe
rm $HOME\.local\bin\uvw.exe -ErrorAction SilentlyContinue
```

---

# Installer dbt-core avec le connecteur Snowflake avec PIP (Windows)

```powershell
python -m pip --version

python -m venv env

.\env\Scripts\activate

python -m pip install --upgrade pip

pip install "dbt-core==1.11.2" "dbt-snowflake==1.11.1"

dbt --version

dbt init jaffle_shop

cd .\jaffle_shop\

dbt debug
```
