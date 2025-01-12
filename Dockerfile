FROM centos:7

MAINTAINER Red Hat, Inc. <container-tools@redhat.com>

LABEL io.projectatomic.nulecule.atomicappversion="0.2.2" \
      io.openshift.generate.job=true \
      io.openshift.generate.token.as=env:TOKEN_ENV_VAR \
      RUN="docker run -it --rm \${OPT1} --privileged -v `pwd`:/atomicapp -v /run:/run -v /:/host --net=host --name \${NAME} -e NAME=\${NAME} -e IMAGE=\${IMAGE} \${IMAGE} -v \${OPT2} run \${OPT3} \${IMAGE}" \
      STOP="docker run -it --rm \${OPT1} --privileged -v `pwd`:/atomicapp -v /run:/run -v /:/host --net=host --name \${NAME} -e NAME=\${NAME} -e IMAGE=\${IMAGE} \${IMAGE} -v \${OPT2} stop \${OPT3}" \
      INSTALL="docker run -it --rm \${OPT1} --privileged -v `pwd`:/atomicapp -v /run:/run -v /:/host --name \${NAME} -e NAME=\${NAME} -e IMAGE=\${IMAGE} \${IMAGE} -v \${OPT2} install \${OPT3} \${IMAGE}"

WORKDIR /opt/atomicapp

# Add the requirements file into the container
ADD requirements.txt /opt/atomicapp/

# Install needed requirements
RUN yum install -y epel-release \
    yum install -y --setopt=tsflags=nodocs docker && \
    yum install -y --setopt=tsflags=nodocs $(sed s/^/python-/ requirements.txt) && \
    yum clean all

WORKDIR /atomicapp
VOLUME /atomicapp

ENV PYTHONPATH  /opt/atomicapp/

# the entrypoint
ENTRYPOINT ["/usr/bin/python", "/opt/atomicapp/atomicapp/cli/main.py"]

# Add all of Atomic App's files to the container image
# NOTE: Do this last so rebuilding after development is fast
ADD atomicapp/ /opt/atomicapp/atomicapp/
ADD setup.py requirements.txt /opt/atomicapp/
