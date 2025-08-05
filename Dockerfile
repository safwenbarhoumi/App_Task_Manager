# Utilise Ubuntu comme base
FROM ubuntu:20.04

# Empêche les prompts interactifs
ENV DEBIAN_FRONTEND=noninteractive

# Dépendances requises
RUN apt-get update && apt-get install -y \
    curl \
    git \
    wget \
    unzip \
    libgconf-2-4 \
    gdb \
    libstdc++6 \
    libglu1-mesa \
    fonts-droid-fallback \
    python3 \
    xz-utils \
    ca-certificates \
    && apt-get clean

# Clone Flutter depuis la branche stable
RUN git clone -b stable https://github.com/flutter/flutter.git /usr/local/flutter

# Ajoute Flutter au PATH
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Accepte la licence Android (si nécessaire)
RUN flutter doctor --android-licenses || true

# Exécute flutter doctor pour télécharger les composants nécessaires
RUN flutter upgrade && flutter doctor

# Définis le dossier de travail
WORKDIR /app

# Copie ton code dans le conteneur
COPY . /app

# Résout les dépendances Flutter
RUN flutter pub get

# Commande par défaut (à adapter)
CMD ["flutter", "build", "apk"]
