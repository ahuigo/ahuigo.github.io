# Perface
selenium 一般用于 Web UI自动化测试

1. Selenium(WebDriver): 自动化测试工具，能驱动IE/Chrome/Firefox 以及无界面的PhantomJS, 支持C/JAVA/Python/Ruby 甚至浏览器插件
2. PhantomJS: 无界面的浏览器, 可非常方便的修改查询页面元素

## AXUI
AXUI provide built-in drivers for:

    windows native UIAutomation Client API for windows desktop UI
    selenium project for web UI
    appium project for Android and IOS UI

# Webdriver

## chrome driver
    from selenium import webdriver

    browser = webdriver.Chrome()
    browser.get('http://www.baidu.com/')

## phantomJs driver

    from selenium import webdriver

    driver = webdriver.PhantomJS(path_to_phantomjs.exe)
    driver.get(url)
    driver.find_element_by_id('result').text
    str = driver.find_element_by_xpath('//*[@id="more"]/dd/div/span').text

# js

## exec js
driver.execute_script('window.scrollTo(0,500)')

## driver js
driver.find_element_by_xpath('//*[@id="more"]/dd/div/span').find_element_by_tag_name('a').click()

### click
going on on your page that would interfere with the click, this should do it:

1. You should use *move_to_element_with_offset* if you want the mouse position to be *relative to an element*.
2. Otherwise, *move_by_offset* moves the mouse relative to the *previous mouse position*.

When you using click or move_to_element, the mouse is placed in the center of the element.

    homeLink = driver.find_element_by_link_text("Home")
    homeLink.click() #clicking on the Home button and mouse cursor should? stay here
    print homeLink.size, homeLink.location

    helpLink = driver.find_element_by_link_text("Help")
    print helpLink.size, helpLink.location

    action = webdriver.common.action_chains.ActionChains(driver)
    action.move_to_element_with_offset(homeLink, 150, 0) #move 150 pixels to the right to access Help link
    action.click()
    action.perform()

# Xpath
http://stackoverflow.com/questions/22571267/how-to-verify-an-xpath-expression-in-chrome-developers-tool-or-firefoxs-firebug
