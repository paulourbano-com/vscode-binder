FROM ubuntu:focal-20220302
ENV TZ=America/Phoenix
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get install -y curl
RUN curl -fsSL https://deb.nodesource.com/setup_12.x | bash -
RUN apt-get install -y nodejs
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list > /etc/apt/sources.list.d/mssql-release.list

RUN apt-get update && apt-get install -y sudo iputils-ping vim neovim \
    python3-neovim python3-neovim htop git curl python3-pip\
    exuberant-ctags ack-grep python3-distutils \
    python3-dev graphviz-dev graphviz make build-essential \
    libssl-dev zlib1g-dev libbz2-dev libreadline-dev \
    libsqlite3-dev wget llvm libncursesw5-dev xz-utils tk-dev \
    libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev unixodbc-dev \
    software-properties-common python-dev pkg-config tig bat screen

RUN ACCEPT_EULA=Y apt-get install -y msodbcsql17

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

RUN jupyter-serverextension enable --py jupyter_server_proxy
RUN jupyter-labextension install @jupyterlab/server-proxy
RUN jupyter-lab build
RUN curl -fsSL https://code-server.dev/install.sh | bash
RUN code-server --install-extension ms-python.python njpwerner.autodocstring mechatroner.rainbow-csv
RUN code-server --install-extension njpwerner.autodocstring 
RUN code-server --install-extension mechatroner.rainbow-csv


RUN mkdir ${HOME}/.vscode && printf '{ \n\
"workbench.colorTheme": "Default Dark+",\n\
"autoDocstring.docstringFormat": "numpy",\n\
"terminal.integrated.copyOnSelection": true,\n\
"python.testing.pytestArgs": [\n\
    "."\n\
],\n\
"python.testing.unittestEnabled": false,\n\
"python.testing.pytestEnabled": true,\n\
"python.formatting.provider": "black",\n\
"editor.formatOnSave": true,\n\
"python.linting.enabled": true,\n\
"python.linting.pylintEnabled": true,\n\
"jupyter.askForKernelRestart": false,\n\
"terminal.integrated.wordSeparators": " ()[]{},\"`-/"\n\
}' > ${HOME}/.vscode/settings.json

RUN mkdir ${HOME}/.ssh && printf 'Host \n\
  User \n\
  Hostname \n\
  IdentityFile ~/.ssh/\n' > ${HOME}/.ssh/config

RUN mkdir ${HOME}/repo_contents
COPY . ${HOME}/repo_contents

RUN pip3 install -e ${HOME}/repo_contents

RUN chown -R ${NB_UID} ${HOME}
ENV PIPENV_PIPFILE=${HOME}/repo_contents/Pipfile
USER ${NB_USER}
RUN python3 -m pipenv install --dev
RUN printf 'export -n PIPENV_PIPFILE\nalias cat=batcat' >> ${HOME}/.bashrc

