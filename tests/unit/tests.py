import os
import subprocess
import sys
import unittest


class TestWebAppResources(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        cls.path = os.path.join(os.path.dirname(os.path.realpath(__file__)), "../../")
        init = subprocess.run(
            ["terraform", f"-chdir={cls.path}", "init", "-backend=false", "-input=false"],
            capture_output=True,
            text=True,
        )
        if init.returncode != 0:
            raise RuntimeError(f"terraform init failed:\n{init.stdout}\n{init.stderr}")

    def setUp(self):
        self.main_tf = self._read_file("main.tf")
        self.trafficman_tf = self._read_file("trafficman.tf")
        self.output_tf = self._read_file("output.tf")

    def _read_file(self, relative_path):
        with open(os.path.join(self.path, relative_path), "r", encoding="utf-8") as file:
            return file.read()

    def test_terraform_validate(self):
        result = subprocess.run(
            ["terraform", f"-chdir={self.path}", "validate"],
            capture_output=True,
            text=True,
        )
        self.assertEqual(
            result.returncode,
            0,
            msg=f"terraform validate failed:\n{result.stdout}\n{result.stderr}",
        )

    def test_native_webapp_resources_present(self):
        self.assertIn('resource "azurerm_service_plan" "app_service_plan"', self.main_tf)
        self.assertIn('resource "azurerm_windows_web_app" "app_service_site"', self.main_tf)
        self.assertIn('resource "azurerm_windows_web_app_slot" "app_service_slot"', self.main_tf)
        self.assertIn('resource "azurerm_app_service_custom_hostname_binding" "additional_host"', self.main_tf)

    def test_native_certificate_resources_present(self):
        self.assertIn('resource "azurerm_app_service_certificate" "app_service_ssl"', self.main_tf)
        self.assertIn('resource "azurerm_app_service_certificate_binding" "app_service_ssl"', self.main_tf)

    def test_traffic_manager_resources_present(self):
        self.assertIn('resource "azurerm_traffic_manager_profile" "tmprofile"', self.trafficman_tf)
        self.assertIn('resource "azurerm_traffic_manager_external_endpoint" "tm_shutter"', self.trafficman_tf)
        self.assertIn('resource "azurerm_traffic_manager_external_endpoint" "tm_app"', self.trafficman_tf)

    def test_arm_template_resources_removed(self):
        self.assertNotIn("azurerm_template_deployment", self.main_tf)
        self.assertNotIn("azurerm_resource_group_template_deployment", self.main_tf)
        self.assertFalse(os.path.exists(os.path.join(self.path, "templates", "asp-app.json")))
        self.assertFalse(os.path.exists(os.path.join(self.path, "templates", "app-ssl.json")))
        self.assertFalse(os.path.exists(os.path.join(self.path, "templates", "trafficmanager.json")))

    def test_outputs_reference_native_webapp(self):
        self.assertIn("azurerm_windows_web_app.app_service_site", self.output_tf)
        self.assertNotIn("azurerm_template_deployment.app_service_site", self.output_tf)

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(TestWebAppResources)
    result = unittest.TextTestRunner(verbosity=1).run(suite)
    sys.exit(not result.wasSuccessful())
