FROM		ubuntu:latest

RUN		apt update && apt upgrade -y && apt install -y \
		pipx	\
		zsh	\
		git	\
		curl	\
		wget	\
		vim

RUN		sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.2.1/zsh-in-docker.sh)" -- \
		-t jonathan \
		-p https://github.com/zsh-users/zsh-autosuggestions \
		-p https://github.com/zsh-users/zsh-syntax-highlighting

RUN		pipx ensurepath && \
		pipx install --include-deps ansible && \
		pipx upgrade --include-injected ansible && \
		pipx inject --include-apps ansible argcomplete

ENV		PATH="/root/.local/bin:${PATH}"

RUN		chsh -s /bin/zsh root

ENTRYPOINT	["/usr/bin/zsh"]
