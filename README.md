# Cadu Barber

Site da Cadu Barber (https://cadubarber.com.br/).

Este repositório contém o build de produção baixado do Netlify, com otimizações de performance aplicadas:

- Imagens comprimidas e redimensionadas (85 MB → 1,6 MB)
- Nomes de arquivo normalizados para minúsculo (evita 404 em deploy no Netlify, que é case-sensitive)
- Seção de galeria (vídeos ausentes) trocada por capas do Instagram com link para os posts originais

Backend: Firebase (Auth + Firestore), configurado no projeto `barbearia-web-30fd0`.

## Rodar localmente

```
powershell -ExecutionPolicy Bypass -File .\serve.ps1
```

Abre em `http://localhost:8853/`.
