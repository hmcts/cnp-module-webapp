import terraform_validate
import unittest
import os


class TestWebAppResources(unittest.TestCase):

    def setUp(self):
        # Tell the module where to find your terraform configuration folder
        self.path = os.path.join(os.path.dirname(os.path.realpath(__file__)),
                                 "../../")
        self.v = terraform_validate.Validator(self.path)

    def test_resourceGroup(self):
        """Assert that resource group have the right properties
        and values.
        """
        self.v.error_if_property_missing()
        self.v.resources('azurerm_resource_group').should_have_properties('["name","location"]')

    def test_template(self):
        """TODO: Docstring for function.

        :arg1: TODO
        :returns: TODO

        """
        pass

    def test_templateDeployment(self):
        """TODO: Docstring for templateDeployment.

        :arg1: TODO
        :returns: TODO

        """
        pass


if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(TestWebAppResources)
    unittest.TextTestRunner(verbosity=0).run(suite)
