# Zafir Tecnologia Website

Landing page para a Zafir Tecnologia construída com HTML puro e Tailwind via CDN.  
Este repositório agora inclui todos os artefactos para empacotar e publicar o site em Kubernetes.

## Conteúdo

- `index.html`, `logo.svg` – site estático
- `nginx/` – configuração Nginx usada no container
- `Dockerfile` – imagem baseada em `nginx:alpine`
- `.deployments/k8s/` – manifestos Kubernetes (Deployment, Service, Ingress)

## Como executar localmente (Docker)

```bash
# Construir a imagem
docker build -t zafir-website:latest .

# Executar localmente
docker run --rm -it -p 8080:80 zafir-website:latest

# Abrir no browser
open http://localhost:8080
```

## Deployment em Kubernetes

### 1. Preparação

```bash
# Namespace (caso ainda não exista)
kubectl create namespace zafir

# Opcional: criar secret TLS utilizado no Ingress
kubectl create secret tls website-zafir-co-ao-tls \
  --cert=path/to/fullchain.pem \
  --key=path/to/privkey.pem \
  --namespace zafir
```

### 2. Build & Push da imagem

```bash
REGISTRY=registry.digitalocean.com/zafir
IMAGE_TAG=zafir-website:$(date +%Y%m%d%H%M)

docker build -t $REGISTRY/$IMAGE_TAG .
docker push $REGISTRY/$IMAGE_TAG
```

Substitua `<IMAGE>` no arquivo `.deployments/k8s/deployment.yaml` pela referência que acabou de enviar.

### 3. Aplicar manifestos

```bash
kubectl apply -f .deployments/k8s/deployment.yaml
```

### 4. Verificação

```bash
# Estado dos pods
kubectl get pods -n zafir -l app=zafir-website

# Logs
kubectl logs -n zafir deployment/zafir-website

# Rollout
kubectl rollout status deployment/zafir-website -n zafir
```

## Estrutura dos manifestos

- **Deployment** – 2 réplicas, probes HTTP em `/healthz`, requests/limits conservadores.
- **Service** – Manifesto combinado no mesmo arquivo expõe a porta 80 via ClusterIP.

Adapte o host e o secret TLS conforme o ambiente em que o site será publicado (caso utilize um Ingress externo ao repositório).

## CI/CD (Tags)

Ao criar uma tag (`git tag v1.0.0 && git push origin v1.0.0`) o workflow em `.github/workflows/deploy.yml`:

1. Constrói a imagem e envia para o Docker Hub.
2. Atualiza `deployment.yaml` com o novo `<IMAGE>`.
3. Aplica o manifesto no cluster DigitalOcean.
4. Aguarda o sucesso do rollout.

### Segredos e variáveis necessários

- `DOCKERHUB_USERNAME` / `DOCKERHUB_TOKEN`
- `DIGITALOCEAN_ACCESS_TOKEN`
- Variável `DIGITALOCEAN_K8S_CLUSTER_NAME` (em “Repository variables”)
