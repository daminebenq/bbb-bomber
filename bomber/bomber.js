const puppeteer = require('puppeteer');
const { sleep } = require('../utils/helper');
const URL = process.argv[2]
const messagesAmount = parseInt(process.argv[4]);
const meetingName = process.argv[5];
const e = require('../utils/elements');

async function bomber() {
    const browser = await puppeteer.launch({
        headless: false,
	    args: ['--no-sandbox']
    });
    const page = await browser.newPage();

    console.log('Starting Time');
    page.on('console', async msg => console[msg._type](
        ...await Promise.all(msg.args().map(arg => arg.jsonValue()))
    ));
    try {
        await page.goto(`${URL}/demo/demoHTML5.jsp?username=MessengerBomber1&meetingname=${meetingName}&isModerator=true&action=create`, { waitUntil : ['load', 'domcontentloaded']});
        await sleep(3000);
        const startTime = new Date().getTime();
        console.log(`Start time at ${startTime}`);
    
        let msgTimestamp = new Date().getTime();
        
        await page.waitForSelector(e.closeAudio, { timeout: 5000 });
        await page.click(e.closeAudio);
        await sleep(5000);

        for (let i = 1; i <= messagesAmount; i += 1) {
          msgTimestamp += 1;
          
          await page.waitForSelector(e.chatTextArea, { timeout: 5000 });
          await page.click(e.chatTextArea);
          await page.keyboard.type(`Message ${i} sent !`);
          await page.keyboard.press('Enter');
    
          await sleep(100); 
        }
        const endTime = new Date().getTime();
        console.log(`All messages sent at ${endTime}. deltaTime=${(endTime - startTime) / 1000}s`);
        process.exit(0)
    } catch (error) {
        console.log({error});
        process.exit(1)
    }
}
bomber();