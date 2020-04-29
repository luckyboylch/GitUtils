# GitUtils

##### 脚本功能：主要用于下载GitHub项目中某个子文件或某个子目录。

##### 示例-下载某个子文件：

```shell
bash downUtils.sh \
--down_url="https://github.com/geekhac/todomvc/blob/master/examples/ampersand/node_modules/todomvc-common/base.css" \
--dst_dir="C:/Users/xxx/Desktop/"
```

##### 示例-下载某个子目录：

```shell
bash downUtils.sh \
--down_url="https://github.com/geekhac/todomvc/tree/master/examples/ampersand/node_modules" \
--dst_dir="C:/Users/xxx/Desktop/"
```

说明：实际还是会下载整个项目，只不过Git操作时会隐藏其他内容。需要提前安装好Git工具。



