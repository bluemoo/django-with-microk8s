from typing import Optional


def get_secret(key: str, default: Optional[str] = None) -> str:
    try:
        with open(f'/etc/secrets/{key}', 'r') as f:
            return f.read()
    except FileNotFoundError:
        if default is not None:
            return default
        raise


SECRET_KEY = get_secret('app-secrets/django-secret-key')
DATABASE_USERNAME = get_secret('database-secrets/username')
DATABASE_PASSWORD = get_secret('database-secrets/password')
