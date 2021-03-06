# Copyright (c) 2020 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
# Contributors:
#   Red Hat, Inc. - initial API and implementation

FROM docker.io/node:8.16.2-alpine as builder

COPY package.json /workspace-loader/
COPY yarn.lock /workspace-loader/
WORKDIR /workspace-loader/
RUN yarn install --ignore-optional
COPY . /workspace-loader/
RUN yarn build && yarn test

FROM docker.io/httpd:2.4.43-alpine
RUN sed -i 's|    AllowOverride None|    AllowOverride All|' /usr/local/apache2/conf/httpd.conf && \
    sed -i 's|Listen 80|Listen 8080|' /usr/local/apache2/conf/httpd.conf && \
    mkdir -p /var/www && ln -s /usr/local/apache2/htdocs /var/www/html && \
    chmod -R g+rwX /usr/local/apache2 && \
    echo "ServerName localhost" >> /usr/local/apache2/conf/httpd.conf
COPY --from=builder /workspace-loader/target/dist/ /usr/local/apache2/htdocs/workspace-loader/loader
