import { LightningElement, track, api } from 'lwc';

export default class TestConsoleUtility extends LightningElement {
    @track currentTime = '';
    @track counter = 0;
    
    // Это свойство необходимо для Utility Bar
    @api height;

    connectedCallback() {
        this.updateTime();
        this.timeInterval = setInterval(() => {
            this.updateTime();
        }, 1000);
    }

    disconnectedCallback() {
        if (this.timeInterval) {
            clearInterval(this.timeInterval);
        }
    }

    updateTime() {
        this.currentTime = new Date().toLocaleTimeString('ru-RU');
    }

    handleIncrement() {
        this.counter++;
    }

    handleReset() {
        this.counter = 0;
    }
}