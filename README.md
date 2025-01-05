![image](https://github.com/user-attachments/assets/ab4f5941-cf5a-4563-a73b-6c07a56c022e)

This IT skills test relies on 3 PCs.

**PC1** - Where the main test is run from 
**PC2** - Where the fake scam popup is run from, and where the file is shared from  
**PC3** - Any PC to get a bios version from  

## Setting up PC1:
0. Install AutoIt https://www.autoitscript.com/cgi-bin/getfile.pl?autoit3/autoit-v3-setup.zip
    - If at any point you get a VCRUNTIME140.dll error, just install these visual c++ redists:  
        [x86: vc_redist.x86.exehttps://aka.ms/vs/16/release/vc_redist.x86.exe](https://aka.ms/vs/16/release/vc_redist.x86.exe)  
        [x64: vc_redist.x64.exehttps://aka.ms/vs/16/release/vc_redist.x64.exe](https://aka.ms/vs/16/release/vc_redist.x64.exe)  
1. Install Google Chrome
2. Ensure network sharing is turned on
3. Right click "Test.au3" and "Run script"
4. You will get a prompt to assign 3 values to a settings.ini file based on your environment _(see "configuring settings" below for more info)_
5. Save the .ini and test all queries and values before proceeding

## Setting up PC2:
0. Install Google Chrome  
1. Ensure there is a password associated with the user account, as we will be sharing files over the network from this account. Keep in mind the tester may have to enter this to open the network shared file on PC1 depending in which route they go.
2. Edit the included Google Chrome shortcut to match the path to ScamExample.html, i.e. `"C:\Program Files\Google\Chrome\Application\chrome.exe" --kiosk C:\Path\To\ScamExample.html`
   *(we use kiosk mode to disable the ability to exit fullscreen using F11)*  
3. Pop the esc key out of PC2's keyboard because that's cheating  
4. Place the 'share' folder on desktop. Inside is a picture of a cat. Any photo will work, but it must be called "photo.jpg" to pass the test on PC1
5. Use the modified Chrome shortcut to open the scam example popup, as simply opening the html file will not enable kiosk mode  

## PC3:
0. Literally just need the bios version from this one.

## Results
After each test is complete, their results and some info will be appended to [`Results.txt`, including:
- How much time remaining after completion, or if time ran out
- How many queries out of 6 were satisfied
- How many times they clicked the X button
- Individual query pass/fail results

## Resetting
After the skills test has been complete, a simple checklist can reset the environment.
1. Remove the printer from the devices on PC1
2. Delete recent browser history from Chrome on PC1
3. Disable the internet however you wish on PC1
4. Stop sharing the file on PC2

## Configuring the settings
**printerpagetitle** - A test query will continuously check if the user has successfully visited the correct printer configuration page. This is a string in string search, so if the full title is `HP Printer - Google Chrome`, simply putting `HP Printer` will do fine.  
**biosversion** - Just put the BIOS version of PC3 here.  
**timelimit** - The time limit __in seconds__ you will give the test taker. Somewhere around 12-15 minutes is what most experienced candidates take.
        
