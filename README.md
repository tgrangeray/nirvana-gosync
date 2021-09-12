# nirvana-gosync

## Installation locale

Prérequis:
- installer golang 1.x
- installer AWS CLI
- Installer Terraform
- Configurer les credentials AWS

#### TODO
- le chemin des credentials AWS est en dur dans terraform/main.tf
- variabiliser la region AWS

#### Installer les dépendances

```
# Installer les dépendances
$ go get -v all
```

## Installer les dépendances, compiler et packager

```
$ compiler pour linux
GOOS=linux go build -o build/main cmd/main.go

$ créer le package
zip -jrm build/main.zip build/main
```

## Déployer et détruire l'environnement AWS

```
cd ./terraform

# déployer
terraform apply

# détruire
terraform destroy
```
