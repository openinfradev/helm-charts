FROM python

ADD https://dl.k8s.io/release/v1.22.0/bin/linux/amd64/kubectl /usr/local/bin/
COPY requirements.txt requirements.txt
COPY generate_machine_pool.py /usr/local/bin/generate_machine_pool.py
RUN pip3 install -r requirements.txt
RUN chmod 755 /usr/local/bin/generate_machine_pool.py /usr/local/bin/kubectl

ENTRYPOINT [ "/usr/local/bin/generate_machine_pool.py" ]