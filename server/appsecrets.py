import os
from typing import Optional


class SecretLoader:
    def __init__(self, rootpath: str) -> None:
        self.rootpath = rootpath

    def get_secret(self, key: str) -> str:
        with open(os.path.join(self.rootpath, key), "r") as f:
            return f.read()


env_rootpath: Optional[str] = os.getenv("SECRETS_ROOTPATH")
assert env_rootpath
loader = SecretLoader(rootpath=env_rootpath)

SECRET_KEY = loader.get_secret("app-secrets/django-secret-key")
DATABASE_USERNAME = loader.get_secret("database-secrets/username")
DATABASE_PASSWORD = loader.get_secret("database-secrets/password")
