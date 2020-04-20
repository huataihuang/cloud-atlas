.. _unittest_simple_app:

==========================
功能测试驱动开发简单应用
==========================

功能测试的作用是跟踪用户行为，模拟用户使用某个功能的过程，以及应用应该如何响应用户的操作。

.. note::

   术语：功能测试(Function Test) = 验收测试(Acceptance Test) = 端到端测试(End-to-End Test)

.. note::

   在 :ref:`jenkins` 完成软件的编译之后，我们会进行一种称为BVT(Build Verification Test)测试，就是在新的build之上跑一系列case来验证这个build功能是否符合预期。这个测试也就是上述的功能测试(Function Test)，验收测试(Acceptance Test)，端到端测试(End-to-End Test)。

功能测试需要一个易读易理解的说明文档。为了叙述清晰，可以把测试代码和代码注释结合起来使用。编写新功能测试时，可以先写注释，以便清晰描述功能，甚至可以作为讨论应用需求和功能的方式分享给非程序员看。

.. note::

   Python结合 :ref:`sphinx_doc` 可以实现完善的文档注释说明。

TDD常和敏捷软件开发方法结合在一起使用。有一个"最简可用应用"的概念，即开发出最简单但是可以使用的应用。

Python注释
==============

在Python(以及其他语言)中，要努力做到让代码可读，使用具有意义的变量名和函数名，保持代码结构清晰，这样就不需要通过注释说明代码做什么。简单重复代码意图的注释不仅无意义，而且容易随着代码迭代而失效并造成混淆。

Python标准库unittest模块
===========================

之前我们编写通过简单的 ``fnctional_test.py`` 来检测Django的title::

   from selenium import webdriver
   browser = webdriver.Firefox()
   browser.get('http://localhost:8000')
   assert 'Django' in browser.title

这里的 ``assert`` (断言) 是功能测试常用的方法。但是自己编写功能测试很难完善输出的debug信息。通常我们会使用Python的标准库 ``unittest`` 模块的解决方案::

   from selenium import webdriver
   import unittest
   
   class NewVisitorTest(unittest.TestCase):
       def setUp(self):
           self.browser = webdriver.Firefox()
   
       def testDown(self):
           self.browser.quit()
   
       def test_can_start_a_list_and_retrieve_it_later(self):
           self.browser.get('http://localhost:8001')
   
           self.assertIn('To-Do', self.browser.title)
           self.fail('Finish the test!')
   
   if __name__ == '__main__':
       unittest.main(warnings='ignore')

- 测试的类继承自 ``unittest.TestCase`` 
- 测试代码写在名为 ``test_can_start_a_list_and_retrieve_it_later`` 的方法中。名为 ``test_`` 开头的方法都是测试方法，由测试运行程序运行。
- ``setUp`` 和 ``tearDown`` 是特殊的方法，分别在测试方法之前和之后运行，这里用两个方法打开和关闭浏览器。
- ``self.assertIn`` 是测试断言。 ``unittest`` 提供了很多用于编写测试断言的辅助函数，如 ``assertEqual`` ``assertTrue`` ``assertFalse`` 等。

- ``if __name__ == '__main__'`` 分句表示Python脚本检查自己是否在命令行运行，而不是在其他脚本中导入。

通过运行 ``unittest`` 的功能测试，可以显示排版精美的报告，以及有利调试的错误信息::

   .F
   ======================================================================
   FAIL: test_can_start_a_list_and_retrieve_it_later (__main__.NewVisitorTest)
   ----------------------------------------------------------------------
   Traceback (most recent call last):
     File "functional_tests.py", line 14, in test_can_start_a_list_and_retrieve_it_later
       self.assertIn('To-Do', self.browser.title)
   AssertionError: 'To-Do' not found in 'Django: the Web framework for perfectionists with deadlines.'
   
   ----------------------------------------------------------------------
   Ran 2 tests in 10.321s
   
   FAILED (failures=1)


