wget https://github.com/elixir-lang/elixir/releases/download/v1.10.3/Precompiled.zip

https://blog.csdn.net/xiangxianghehe/article/details/78870176

wget https://github.com/elixir-lang/elixir/releases/download/v1.5.3/Precompiled.zip
mkdir -p /usr/local/elixir_1.5.3
cp Precompiled.zip /usr/local/elixir_1.5.3
cd /usr/local/elixir_1.5.3
unzip Precompiled.zip

vim /etc/profile

export ELIXIR_HOME=/usr/local/elixir_1.5.3
export PATH="$PATH:$ELIXIR_HOME/bin"