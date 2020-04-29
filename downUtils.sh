#!/usr/bin/env bash

function parse_dir_path()
{
  sub_dir=${1}
  sub_dir=${sub_dir//\\//}

  if [[ ${sub_dir:0:1} != "/" ]]
  then
    sub_dir=/${sub_dir}
  fi
  len=${#sub_dir}
  if [[ ${sub_dir:len-1:len} != "/" ]]
  then
    sub_dir=${sub_dir}/
  fi
  sub_dir=${sub_dir}*
  # return只能返回整数
  echo ${sub_dir}
}

function parse_file_path()
{
  sub_file=${1}
  sub_file=${sub_file//\\//}
  if [[ ${sub_file:0:1} != "/" ]]
  then
    sub_file=/${sub_file}
  fi
  echo ${sub_file}
}

function download_sub_dir()
{
  remote_path=${1}
  sub_dir=${2}
  dst_dir=${3}

  # 创建临时目录
  TMPDIR=$(mktemp -d)||exit 1

  cd $TMPDIR
  tmp_git="tmpGit"
  git init $tmp_git
  tmp_dst_dir=${TMPDIR}/${tmp_git}
  cd $tmp_dst_dir
  git config core.sparsecheckout true
  tmp_sub_dir=$(parse_dir_path ${sub_dir})
  echo ${tmp_sub_dir} >> .git/info/sparse-checkout
  git remote add origin ${remote_path}
  git pull origin master

  cp_dir=${tmp_dst_dir}/${tmp_sub_dir:1:-2}
  if [[ -e ${dst_dir} ]]
  then
    cp -r ${cp_dir} ${dst_dir}
  fi
  # 获取目录名
  dir_name=${cp_dir##*/}

  cd ~
  rm -rf ${TMPDIR}

  echo "download subdir ${sub_dir} from ${remote_path} success"
}

function download_sub_file()
{
  remote_path=${1}
  sub_file=${2}
  dst_dir=${3}

  # 创建临时目录
  TMPDIR=$(mktemp -d)||exit 1

  cd $TMPDIR
  tmp_git="tmpGit"
  git init $tmp_git
  tmp_dst_dir=${TMPDIR}/${tmp_git}
  cd $tmp_dst_dir
  git config core.sparsecheckout true
  tmp_sub_file=$(parse_file_path ${sub_file})
  echo ${tmp_sub_file} >> .git/info/sparse-checkout
  git remote add origin ${remote_path}
  git pull origin master

  cp_file=${tmp_dst_dir}/${tmp_sub_file}
  if [[ -e ${dst_dir} ]]
  then
    cp ${cp_file} ${dst_dir}
  fi

  cd ~
  rm -rf ${TMPDIR}

  echo "download subfile ${sub_file} from ${remote_path} success"
}

# 命令行按名字传参并解析
show_usage="[Usage] -U <DOWN_URL> -D <DST_DIR>"
GETOPT_ARGS=`getopt -o U:D: -al down_url:,dst_dir: -- "$@"`
eval set -- "$GETOPT_ARGS"
while [ -n "$1" ]
do
        case "$1" in
                -U|--down_url) down_url=$2; shift 2;;
                -D|--dst_dir) dst_dir=$2; shift 2;;
                --) break ;;
                *) echo $show_usage; exit 1;;
        esac
done

if [[ -z $down_url || -z $dst_dir ]]; then
        echo "parm error"
        echo $show_usage
        exit 0
fi

# 解析下载URL：/blob对应文件；/tree对应目录
file_infix="/blob"
dir_infix="/tree"
len_file_infix=${#file_infix}
len_dir_infix=${#dir_infix}
len=${#down_url}
# 利用awk查找子串：awk中引用shell变量必须是"'"$var"'"
res=`echo $down_url | awk 'BEGIN{print index("'"$down_url"'","'"$file_infix"'")}'`
if [[ $res -ne 0 ]]; then
  # 若下载子文件
  remote_path=${down_url:0:res-1}".git"
  sub_file=${down_url:res+len_file_infix:len}
  sub_file=${sub_file#*/}
  echo $sub_file
  download_sub_file ${remote_path} ${sub_file} ${dst_dir}
else
  # 若下载子目录
  res=`echo $down_url | awk 'BEGIN{print index("'"$down_url"'","'"$dir_infix"'")}'`
  if [[ $res -ne 0 ]]; then
    remote_path=${down_url:0:res-1}".git"
    sub_dir=${down_url:res+len_dir_infix:len}
    sub_dir=${sub_dir#*/}
    echo $sub_dir
    download_sub_dir ${remote_path} ${sub_dir} ${dst_dir}
  fi
fi

# 说明：实际还是会下载整个项目，只不过会隐藏其他内容
# bash downUtils.sh --down_url="https://github.com/geekhac/todomvc/blob/master/examples/ampersand/node_modules/todomvc-common/base.css" --dst_dir="C:/Users/xxx/Desktop/"
# bash downUtils.sh --down_url="https://github.com/geekhac/todomvc/tree/master/examples/ampersand/node_modules" --dst_dir="C:/Users/xxx/Desktop/"







