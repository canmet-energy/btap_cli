ARG OPENSTUDIO_VERSION='3.0.1'
FROM canmet/docker-openstudio:$OPENSTUDIO_VERSION
# Need to remind Docker of the Openstudio version..https://docs.docker.com/engine/reference/builder/
ARG OPENSTUDIO_VERSION
# Branch information.
ARG BTAP_COSTING_BRANCH=''
ARG OS_STANDARDS_BRANCH='nrcan_prod'


# Git api token secret. Do not share as a ENV.
ARG GIT_API_TOKEN='nothing'
MAINTAINER Phylroy Lopez phylroy.lopez@canada.ca
# Set X session url..if needed.
ARG DISPLAY=host.docker.internal
ENV DISPLAY ${DISPLAY}

# Set Ruby lib to use the version of OS.
ENV RUBYLIB=/usr/local/openstudio-${OPENSTUDIO_VERSION}/Ruby:/usr/Ruby

#Be root and install btap_costing under the root folder.
USER  root
WORKDIR /

## The following are security update required by StatsCan.

#Remove openstudio-extensions from /usr/local/openstudio-${OPENSTUDIO_VERSION}/Ruby
WORKDIR /usr/local/openstudio-${OPENSTUDIO_VERSION}/Ruby
RUN sed -i '/^.*openstudio-extension.*$/d' Gemfile \
&& sed -i '/^.*openstudio-extension.*$/d' openstudio-gems.gemspec \
&& bundle install \
&& bundle update simplecov-html \
&& bundle clean --force

#Remove openstudio-extensions from var/oscli
WORKDIR /var/oscli
RUN sed -i '/^.*openstudio-extension.*$/d' Gemfile \
&& sed -i '/^.*openstudio-extension.*$/d' openstudio-gems.gemspec \
&& bundle install \
&& bundle update simplecov-html \
&& bundle clean --force

#Apply security updates
RUN apt-get update \
&& apt-get upgrade -y --no-install-recommends --force-yes \
&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
&& apt-get clean


RUN if [ -z "$BTAP_COSTING_BRANCH" ] ; then \
        echo "Creating Public CLI witout costing"; \
        git clone https://$GIT_API_TOKEN:x-oauth-basic@github.com/NREL/openstudio-standards.git --depth 1 --branch ${OS_STANDARDS_BRANCH} --single-branch /btap_costing ; \
        cd /btap_costing; \
        bundle install; \
        echo 'standards revision'; \
        git rev-parse --short HEAD;\
    else\
        echo "Creating Private CLI with Costing"; \
        git clone https://$GIT_API_TOKEN:x-oauth-basic@github.com/canmet-energy/btap_costing.git --depth 1 --branch ${BTAP_COSTING_BRANCH} --single-branch /btap_costing; \
        cd /btap_costing; \
        sed -i '/^.*standards.*$/d' Gemfile; \
        echo "gem 'openstudio-standards', :github => 'NREL/openstudio-standards', :branch => '${OS_STANDARDS_BRANCH}'" | tee -a Gemfile; \
        bundle install; \
        echo 'btap_costing revision'; \
        git rev-parse --short HEAD; \
    fi

# Make folders that will map to host drives.
WORKDIR /btap_costing/utilities/btap_cli
RUN mkdir output
RUN mkdir input
CMD ["/bin/bash"]

#Sample invocation commands

