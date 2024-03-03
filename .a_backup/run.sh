if [[ ! -d ".venv" || $(python3 --version | awk '{print $2}') != $(source .venv/bin/activate && python3 --version | awk '{print $2}') ]]; then
    rm -rf .venv
    python3 -m venv .venv
    echo "Virtual environment created."
fi

if [[ -z $VIRTUAL_ENV ]]; then
    source .venv/bin/activate
    echo "Virtual environment activated."
fi

pip install --upgrade pip
echo "Upgraded pip."

pip install -r requirements.txt
echo "Installed requirements."

read -p "Do you want to install/continue with Redis for the scalable version of the app? (y/n)('n' if you are currently developing the app): " use_redis

if [[ $use_redis == "y" ]]; then
    if ! command -v redis-cli &> /dev/null; then
        echo "redis-cli command not found. Please install Redis and try again."
        exit 1
    fi

    echo "Redis Found!!"

    if [[ $(uname) == "Linux" ]]; then
        if [[ -x "$(command -v systemctl)" ]]; then
            sudo systemctl restart redis
        else
            sudo service redis restart
        fi
    elif [[ $(uname) == "Darwin" ]]; then
        brew services restart redis
    else
        echo "Unsupported operating system."
        exit 1
    fi

    echo "Redis server started."
fi



echo "All set! You can now run the app."
echo "gunicorn is recommended for production use.Use python for development purposes."
read -p "Enter '1' to run 'python app' or '2' to run 'WSGI(gunicorn) with 4 worker threads': " choice
if [[ $choice == "1" ]]; then
    if [[ $use_redis == "y" ]]; then
        python app_sessions_scalable.py
    else
        python app_sessions.py
    fi
elif [[ $choice == "2" ]]; then
    if [[ $use_redis == "y" ]]; then
        gunicorn -w 4 -b 0.0.0.0:5000 app_sessions_scalable:app
    else
        gunicorn -w 4 -b 0.0.0.0:5000 app_sessions:app
    fi
else
    echo "Invalid choice."
    exit 1
fi
