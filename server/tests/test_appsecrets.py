import pathlib
from unittest import TestCase

from appsecrets import DATABASE_PASSWORD, DATABASE_USERNAME, SecretLoader


class AppSecretsIntegrationTest(TestCase):
    def test_should_load_kubernetes_secrets(self) -> None:
        self.assertEqual(DATABASE_USERNAME, "postgresadmin")
        self.assertEqual(DATABASE_PASSWORD, "postgrespwd")


class SecretLoaderTests(TestCase):
    def setUp(self) -> None:
        self.rootpath = f"{pathlib.Path(__file__).parent.absolute()}/fakesecrets"

    def test_should_load_secrets_from_specified_secrets_root(self) -> None:
        loader = SecretLoader(self.rootpath)

        self.assertEqual(loader.get_secret("secret-a/foo-key"), "foo")

    def test_should_load_keys_from_multiple_secrets(self) -> None:
        loader = SecretLoader(self.rootpath)

        self.assertEqual(loader.get_secret("secret-a/bar-key"), "bar")
        self.assertEqual(loader.get_secret("secret-b/another-one"), "thisisavalue")
