FROM messense/manylinux2014-cross:aarch64

ARG LLVM_VERSION=19

ENV RUSTUP_HOME=/usr/local/rustup \
  CARGO_HOME=/usr/local/cargo \
  PATH=/usr/local/cargo/bin:$PATH \
  CC=clang \
  CXX=clang++ \
  CC_aarch64_unknown_linux_gnu="clang --sysroot=/usr/aarch64-unknown-linux-gnu/aarch64-unknown-linux-gnu/sysroot" \
  CXX_aarch64_unknown_linux_gnu="clang++ --sysroot=/usr/aarch64-unknown-linux-gnu/aarch64-unknown-linux-gnu/sysroot" \
  C_INCLUDE_PATH="/usr/aarch64-unknown-linux-gnu/aarch64-unknown-linux-gnu/sysroot/usr/include" \
  CFLAGS="-fuse-ld=lld --sysroot=/usr/aarch64-unknown-linux-gnu/aarch64-unknown-linux-gnu/sysroot" \
  CXXFLAGS="--sysroot=/usr/aarch64-unknown-linux-gnu/aarch64-unknown-linux-gnu/sysroot -L/usr/aarch64-unknown-linux-gnu/lib/llvm-${LLVM_VERSION}/lib -stdlib=libc++"

COPY ./lib/llvm-${LLVM_VERSION} /usr/aarch64-unknown-linux-gnu/lib/llvm-${LLVM_VERSION}

RUN apt-get update && \
  apt-get install -y --fix-missing --no-install-recommends gpg-agent ca-certificates openssl && \
  wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - && \
  echo "deb http://apt.llvm.org/jammy/ llvm-toolchain-jammy-${LLVM_VERSION} main" >> /etc/apt/sources.list && \
  echo "deb-src http://apt.llvm.org/jammy/ llvm-toolchain-jammy-${LLVM_VERSION} main" >> /etc/apt/sources.list && \
  curl -sL https://deb.nodesource.com/setup_22.x | bash - && \
  apt-get install -y --fix-missing --no-install-recommends \
  curl \
  llvm-${LLVM_VERSION} \
  clang-${LLVM_VERSION} \
  lld-${LLVM_VERSION} \
  libc++-${LLVM_VERSION}-dev \
  libc++abi-${LLVM_VERSION}-dev \
  nodejs \
  xz-utils \
  rcs \
  git \
  make \
  cmake \
  ninja-build && \
  apt-get autoremove -y && \
  curl https://sh.rustup.rs -sSf | sh -s -- -y && \
  rustup target add aarch64-unknown-linux-gnu && \
  npm install -g yarn pnpm lerna && \
  npm cache clean --force && \
  npm cache verify && \
  ln -sf /usr/bin/clang-${LLVM_VERSION} /usr/bin/clang && \
  ln -sf /usr/bin/clang++-${LLVM_VERSION} /usr/bin/clang++ && \
  ln -sf /usr/bin/lld-${LLVM_VERSION} /usr/bin/lld && \
  ln -sf /usr/bin/clang-${LLVM_VERSION} /usr/bin/cc && \
  cp -r /usr/aarch64-unknown-linux-gnu/lib/gcc /usr/aarch64-unknown-linux-gnu/aarch64-unknown-linux-gnu/sysroot/lib/ && \
  rm -rf /var/lib/apt/lists/*
