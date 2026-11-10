# 群晖 RSSHub 独立安装 Node.js 24.15.0 + pnpm 12.16.1

采用项目目录独立部署方案，所有运行环境、pnpm 和依赖缓存都保存在 RSSHub 目录，不修改群晖系统环境、全局 nvm 或其他项目。

## 一、最终目标

| 项目        | 版本 / 路径               |
| --------- | --------------------- |
| 操作系统架构    | Linux x86-64          |
| Node.js   | 24.15.0               |
| npm       | 11.12.1（随 Node 附带）    |
| pnpm      | 12.16.1               |
| Node 安装目录 | `.runtime/node`       |
| pnpm 安装目录 | `.runtime/pnpm`       |
| pnpm 缓存目录 | `.runtime/pnpm-store` |
| 临时目录      | `.runtime/tmp`        |

## 二、创建项目运行环境

进入 RSSHub：

```
cd /volume1/docker/rsshub

mkdir -p .runtime/node
mkdir -p .runtime/pnpm
mkdir -p .runtime/tmp
mkdir -p .runtime/pnpm-store
```

## 三、下载 Node.js 24.15.0

下载官方 Linux x64 二进制包：

```
cd /volume1/docker/rsshub

curl -fL https://nodejs.org/dist/v24.15.0/node-v24.15.0-linux-x64.tar.xz \
  -o .runtime/tmp/node-v24.15.0-linux-x64.tar.xz
```

校验 SHA256：

```
echo "472655581fb851559730c48763e0c9d3bc25975c59d518003fc0849d3e4ba0f6  .runtime/tmp/node-v24.15.0-linux-x64.tar.xz" \
  | sha256sum -c -
```

显示 `OK` 即校验通过。

解压：

```
tar -xJf .runtime/tmp/node-v24.15.0-linux-x64.tar.xz \
  -C .runtime/node --strip-components=1
```

验证：

```
.runtime/node/bin/node -v
.runtime/node/bin/npm -v
```

预期：

```
v24.15.0
11.12.1
```

官方来源：[Node.js 24.15.0 下载页面](https://nodejs.org/en/download/archive/v24.15.0?utm_source=chatgpt.com)。

[image](https://www.google.com/s2/favicons?domain=https://nodejs.org\&sz=32)

Run JavaScript Everywhere+1



## 四、安装独立 pnpm 12.16.1

之前安装失败的原因主要是安装脚本尝试在 `/tmp` 执行下载的 pnpm，可能受到群晖 `noexec` 挂载限制。

另外，系统缺少 `getconf`，导致安装脚本输出架构检测警告。

解决方法：将临时目录也放在 RSSHub 项目中。

```
cd /volume1/docker/rsshub

curl -fsSL https://get.pnpm.io/install.sh | env \
  TMPDIR="$PWD/.runtime/tmp" \
  PNPM_HOME="$PWD/.runtime/pnpm" \
  PNPM_NO_MODIFY_PATH=1 \
  PNPM_VERSION=12.16.1 \
  SHELL=/bin/sh sh -
```

参数说明：

| 参数                      | 作用              |
| ----------------------- | --------------- |
| `TMPDIR`                | 临时文件放在 RSSHub 内 |
| `PNPM_HOME`             | pnpm 独立安装目录     |
| `PNPM_NO_MODIFY_PATH=1` | 不修改系统 PATH      |
| `PNPM_VERSION`          | 固定 pnpm 版本      |
| `SHELL`                 | 指定安装脚本使用的 Shell |

验证：

```
.runtime/pnpm/bin/pnpm --version
```

预期输出：

```
12.16.1
```

pnpm 官方安装说明：[pnpm Installation](https://pnpm.io/installation?utm_source=chatgpt.com)。

[image](https://www.google.com/s2/favicons?domain=https://pnpm.io\&sz=32)

pnpm+1



## 五、创建独立运行脚本

不需要每次手动设置 PATH，创建一个项目专用启动器。

```
cd /volume1/docker/rsshub

cat > rsshub-local.sh <<'EOF'
#!/bin/sh

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"

export PNPM_HOME="$ROOT/.runtime/pnpm"
export PATH="$ROOT/.runtime/node/bin:$PNPM_HOME/bin:$PATH"

exec "$@"
EOF

chmod +x rsshub-local.sh
```

这个脚本的作用是：

1. 优先调用 RSSHub 自带的 Node.js。
2. 优先调用 RSSHub 自带的 pnpm。
3. 不影响系统原有 Node.js、nvm 和 pnpm。
4. 不修改系统环境变量。

## 六、安装 RSSHub 依赖

在 RSSHub 根目录执行：

```
./rsshub-local.sh pnpm install \
  --store-dir "$PWD/.runtime/pnpm-store"
```

依赖安装后，`node_modules` 正常保留在 RSSHub 项目目录。

## 七、构建 RSSHub

执行：

```
./rsshub-local.sh pnpm build
```

也可以先检查项目支持的构建脚本：

```
./rsshub-local.sh node -p \
  "JSON.stringify(require('./package.json').scripts, null, 2)"
```

如果使用此前的路由构建流程：

```
./rsshub-local.sh pnpm run build:routes
./rsshub-local.sh pnpm exec tsdown
```

## 八、验证所有环境

一次性检查：

```
cd /volume1/docker/rsshub

./rsshub-local.sh node -v
./rsshub-local.sh npm -v
./rsshub-local.sh pnpm --version

which node
which pnpm
```

前三项应该分别显示：

```
v24.15.0
11.12.1
12.16.1
```

`which node` 和 `which pnpm` 则应该指向 RSSHub 项目内的 `.runtime` 目录。

## 九、最终目录结构

```
/volume1/docker/rsshub/
│
├── .runtime/
│   ├── node/
│   │   └── bin/
│   │       ├── node
│   │       └── npm
│   │
│   ├── pnpm/
│   │   └── bin/
│   │       └── pnpm
│   │
│   ├── pnpm-store/
│   │
│   └── tmp/
│
├── rsshub-local.sh
├── node_modules/
├── package.json
├── pnpm-lock.yaml
├── lib/
└── ...
```

## 十、群晖特殊问题排查

如果重新安装 pnpm 后仍然报 `Permission denied`，检查项目目录是否也禁止执行：

```
printf '#!/bin/sh\necho exec-ok\n' > .runtime/tmp/test-exec

chmod +x .runtime/tmp/test-exec

.runtime/tmp/test-exec
```

正常应该输出：

```
exec-ok
```

如果这里也报 `Permission denied`，需要检查 `/volume1` 的挂载参数，而不是继续重复安装 pnpm。

另外，之前 RSSHub 遇到的 `EMFILE: too many open files` 属于文件句柄限制，与 Node.js 版本及 pnpm 安装相互独立，需要单独处理。

最终使用方式：

以后在 RSSHub 目录，只需要：

```
# 安装依赖
./rsshub-local.sh pnpm install \
  --store-dir "$PWD/.runtime/pnpm-store"

# 构建
./rsshub-local.sh pnpm build
```

这样 RSSHub 就拥有独立的 Node.js 和 pnpm 运行环境，不会干扰群晖其他项目。


## 需要升级到 Node.js 24.15.0 或 26.13.0
```sh
node -v
v22.22.3
node -p "require('./package.json').engines"
{ node: '^24.15.0 || ^26.13.0' }
```

## 群晖构建报错：Error: EMFILE: too many open files 解决办法
```sh
su - <user>
ulimit -n 65535
cd rsshub
rm -rf node_modules
./rsshub-local.sh pnpm store prune
./rsshub-local.sh pnpm install --frozen-lockfile
./rsshub-local.sh pnpm build
./rsshub-local.sh pnpm start
```
