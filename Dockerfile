FROM centos:centos7.4.1708

LABEL maintainer="m.s.vanvliet@lacdr.leidenuniv.nl"

ARG anaconda_installer=Anaconda3-5.2.0-Linux-x86_64.sh
ARG rstudio_server_installer=rstudio-server-rhel-1.1.456-x86_64.rpm

RUN echo "export PATH=\"/tmp/anaconda3/bin:$PATH\"" >> ~/.bashrc && \
    echo "alias R='/tmp/anaconda3/bin/R'" >> ~/.bashrc && \
    echo "alias Rscript='/tmp/anaconda3/bin/Rscript'" >> ~/.bashrc && \
    echo "alias pip='/tmp/anaconda3/bin/pip'" >> ~/.bashrc && \        
    echo "alias python='/tmp/anaconda3/bin/python'" >> ~/.bashrc && \            
    echo "alias conda='/tmp/anaconda3/bin/conda'" >> ~/.bashrc && \
    echo "alias jupyter='/tmp/anaconda3/bin/jupyter'" >> ~/.bashrc && \
    echo "alias jupyterhub='/tmp/anaconda3/bin/jupyterhub'" >> ~/.bashrc && \
    echo "Install RStudio and Jupyter(hub/labs) and dependencies" && \
    source ~/.bashrc && \
    yum update -y && yum groupinstall -y "Development tools" && yum install epel-release -y && \
    yum install -y cairo-devel libjpeg-turbo-devel nodejs openssl nano htop git R && \
    npm install -g configurable-http-proxy && \
    curl -O https://repo.continuum.io/archive/$anaconda_installer && bash $anaconda_installer -b -f -p /tmp/anaconda3 && rm -rf $anaconda_installer && \
    conda install -n base conda && \
    conda install -y -c conda-forge pyzmq r-memoise jupyterhub jupyterlab && \
    conda install -y -c r r-essentials r-git2r r-devtools r-pbdzmq r-repr r-irdisplay r-evaluate r-crayon r-uuid r-digest r-irkernel && \
    jupyter labextension install -y @jupyterlab/hub-extension@0.9.2 && \
    pip install --no-cache-dir --upgrade pip && pip install --no-cache-dir dockerspawner && \
    jupyterhub --generate-config && mkdir /etc/jupyterhub && mv jupyterhub_config.py /etc/jupyterhub/ && \
    echo >> /etc/jupyterhub/jupyterhub_config.py && \
    echo "c.Spawner.cmd = ['/tmp/anaconda3/bin/jupyter-labhub']" >> /etc/jupyterhub/jupyterhub_config.py && \
    echo >> /etc/jupyterhub/jupyterhub_config.py && \   
    echo '{"argv": ["/tmp/anaconda3/bin/R", "--slave", "-e", "IRkernel::main()", "--args", "{connection_file}"], "display_name":"R", "language":"R"}' > /tmp/anaconda3/share/jupyter/kernels/ir/kernel.json && \
    echo "Install bash kernel" && \
    pip install bash_kernel && python -m bash_kernel.install && \
    echo "Install RStudio" && \
    curl -O https://download2.rstudio.org/$rstudio_server_installer && \
    yum install -y $rstudio_server_installer initscripts && rm -rf $rstudio_server_installer && \
    echo 'www-port=8787' > /etc/rstudio/rserver.conf && \
    rstudio-server verify-installation && \
    conda clean --all && \
    yum clean all && \
    rm -rf /var/cache/yum

CMD ["/tmp/anaconda3/bin/jupyterhub --help"]
