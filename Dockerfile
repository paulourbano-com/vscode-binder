FROM ubuntu:focal-20230308
ENV TZ=America/Phoenix
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update && apt-get install -y curl
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
RUN apt-get install -y nodejs
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list > /etc/apt/sources.list.d/mssql-release.list
RUN apt-get update && apt-get install -y sudo iputils-ping vim neovim gzip\
    python3-neovim python3-neovim htop git curl python3-pip\
    exuberant-ctags ack-grep python3-distutils unzip tmux \
    python3-dev graphviz-dev graphviz make build-essential \
    libssl-dev zlib1g-dev libbz2-dev libreadline-dev openjdk-11-jdk \
    libsqlite3-dev wget llvm libncursesw5-dev xz-utils tk-dev \
    libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev unixodbc-dev \
    software-properties-common python-dev pkg-config tig bat screen \
    firefox libdbus-glib-1-2 libdbusmenu-glib4 libdbusmenu-gtk3-4 xul-ext-ubufox \
    texlive texlive-xetex
RUN ACCEPT_EULA=Y apt-get install -y msodbcsql17
RUN wget https://downloads.gradle-dn.com/distributions/gradle-7.4.2-bin.zip -P /tmp && \
    unzip -d /opt/gradle /tmp/gradle-7.4.2-bin.zip && \
    sudo ln -s /opt/gradle/gradle-7.4.2 /opt/gradle/latest
RUN wget https://github.com/browsh-org/browsh/releases/download/v1.6.4/browsh_1.6.4_linux_amd64.deb && \
    dpkg -i browsh_1.6.4_linux_amd64.deb && \
    rm browsh_1.6.4_linux_amd64.deb
RUN wget https://github.com/quarto-dev/quarto-cli/releases/download/v0.9.610/quarto-0.9.610-linux-amd64.deb && \
    dpkg -i quarto-0.9.610-linux-amd64.deb && \
    rm quarto-0.9.610-linux-amd64.deb
ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV NB_UID ${NB_UID}
ENV HOME /home/${NB_USER}
RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}
RUN echo "${NB_USER}:${NB_USER}" | chpasswd
RUN usermod -aG sudo ${NB_USER}
WORKDIR ${HOME}
RUN pip3 install --no-cache-dir notebook jupyterhub jupyterlab jupyter jupyter-server-proxy pipenv setuptools_rust


COPY . .
RUN pip3 install -e .
RUN chown -R ${NB_UID} ${HOME}
USER ${NB_USER}
RUN mkdir .venv
RUN python3 -m pipenv install --dev
RUN .venv/bin/pip install fsspec==2022.11.0 protobuf==3.20.0
RUN mkdir -p .config/nvim
RUN curl https://raw.githubusercontent.com/fisadev/fisa-vim-config/v12.0.1/config.vim > .config/nvim/init.vim
RUN curl https://raw.githubusercontent.com/vimlab/split-term.vim/master/plugin/split-term.vim >> .config/nvim/init.vim
RUN echo 'set foldmethod=indent' >> .config/nvim/init.vim
RUN echo 'set foldlevelstart=9999' >> .config/nvim/init.vim
RUN echo 'set mouse=n' >> .config/nvim/init.vim
RUN printf 'export -n PIPENV_PIPFILE\n\
            alias cat=batcat\n\
            export GRADLE_HOME=/opt/gradle/latest\n\
            export PATH=${GRADLE_HOME}/bin:${PATH}' >> ${HOME}/.bashrc
RUN git config --global user.name "" && git config --global user.email ""
RUN mkdir .ssh
