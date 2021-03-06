# Copyright 2015 The Kubernetes Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Copyright 2016, Z Lab Corporation. All rights reserved.
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.

FROM k8s.gcr.io/debian-base-amd64:0.3

COPY extra-mrbgem.patch /

RUN /usr/local/bin/clean-install git g++ make binutils autoconf automake autotools-dev libtool pkg-config \
        zlib1g-dev libssl-dev libev-dev libjemalloc-dev ruby-dev libc-ares-dev bison patch \
        zlib1g libssl1.1 libev4 libjemalloc1 libc-ares2 \
        ca-certificates psmisc \
        python && \
    git clone -b v1.32.0 --depth 1 https://github.com/nghttp2/nghttp2.git && \
    cd nghttp2 && \
    patch -p1 < /extra-mrbgem.patch && \
    git submodule update --init && autoreconf -i && \
    ./configure --disable-examples --disable-hpack-tools --disable-python-bindings --with-mruby --with-neverbleed && \
    make -j$(nproc) install-strip && \
    cd .. && \
    rm -rf nghttp2 && \
    apt-get -y purge git g++ make binutils autoconf automake autotools-dev libtool pkg-config \
        zlib1g-dev libssl-dev libev-dev libjemalloc-dev ruby-dev libc-ares-dev bison patch && \
    apt-get -y autoremove --purge && \
    rm -rf /var/log/* && \
    rm /extra-mrbgem.patch

RUN mkdir -p /var/log/nghttpx

COPY nghttpx-ingress-controller /
COPY nghttpx.tmpl /
COPY nghttpx-backend.tmpl /
COPY default.tmpl /
COPY cat-ocsp-resp.sh /

WORKDIR /

CMD ["/nghttpx-ingress-controller"]
