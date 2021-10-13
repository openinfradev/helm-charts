FROM python

ADD https://dl.k8s.io/release/v1.22.0/bin/linux/amd64/kubectl /usr/local/bin/kubectl
ADD https://github.com/argoproj/argo-cd/releases/download/v2.1.1/argocd-linux-amd64 /usr/local/bin/argocd 
ADD https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 /get_helm.sh
ADD https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 /usr/local/bin/jq

COPY requirements.txt requirements.txt
COPY generate_machine_pool.py /usr/local/bin/generate_machine_pool.py
COPY gh /usr/local/bin/gh

RUN pip3 install -r requirements.txt
RUN chmod +x /get_helm.sh
RUN /get_helm.sh
RUN chmod +x /usr/local/bin/argocd /usr/local/bin/generate_machine_pool.py /usr/local/bin/kubectl /usr/local/bin/gh /usr/local/bin/jq

ENTRYPOINT [ "/usr/local/bin/generate_machine_pool.py" ]