/**
 * DarkRP Modern HUD - JavaScript Controller
 * Handles HUD updates and animations
 */

class DarkRPHUD {
    constructor() {
        this.elements = {
            health: document.getElementById('health-value'),
            healthFill: document.getElementById('health-fill'),
            healthLabel: document.getElementById('health-label'),
            armor: document.getElementById('armor-value'),
            armorFill: document.getElementById('armor-fill'),
            money: document.getElementById('money-amount'),
            job: document.getElementById('job-name'),
            salary: document.getElementById('salary-value'),
            ammo: document.getElementById('ammo-current'),
            ammoReserve: document.getElementById('ammo-reserve'),
            killfeed: document.getElementById('killfeed')
        };

        this.lastData = {};
        this.killQueue = [];
        
        console.log('[DarkRP HUD] Initialized');
    }

    /**
     * Update HUD with new data from GMod
     * @param {Object} data - HUD data from Lua
     */
    update(data) {
        if (!data) return;

        // Update health
        if (data.health !== undefined) {
            this.updateHealth(data.health, data.maxHealth || 100);
        }

        // Update armor
        if (data.armor !== undefined) {
            this.updateArmor(data.armor);
        }

        // Update money
        if (data.money !== undefined) {
            this.animateNumber(this.elements.money, this.lastData.money || 0, data.money);
        }

        // Update job
        if (data.job !== undefined) {
            this.elements.job.textContent = data.job.toUpperCase();
        }

        // Update salary
        if (data.salary !== undefined) {
            this.elements.salary.textContent = '$' + data.salary;
        }

        // Update ammo
        if (data.ammo !== undefined) {
            this.updateAmmo(data.ammo, data.ammoReserve || 0);
        }

        this.lastData = data;
    }

    /**
     * Update health display
     */
    updateHealth(health, maxHealth) {
        const percentage = Math.max(0, Math.min(100, (health / maxHealth) * 100));
        const isLow = percentage < 25;

        this.animateNumber(this.elements.health, this.lastData.health || 100, Math.round(percentage));
        this.elements.healthFill.style.width = percentage + '%';

        // Apply low health styling
        if (isLow) {
            this.elements.health.classList.add('low-health');
            this.elements.healthFill.classList.add('low-health');
            this.elements.healthLabel.classList.add('low-health');
        } else {
            this.elements.health.classList.remove('low-health');
            this.elements.healthFill.classList.remove('low-health');
            this.elements.healthLabel.classList.remove('low-health');
        }
    }

    /**
     * Update armor display
     */
    updateArmor(armor) {
        const percentage = Math.max(0, Math.min(100, armor));
        this.animateNumber(this.elements.armor, this.lastData.armor || 0, Math.round(percentage));
        this.elements.armorFill.style.width = percentage + '%';
    }

    /**
     * Update ammo display
     */
    updateAmmo(current, reserve) {
        this.animateNumber(this.elements.ammo, this.lastData.ammo || 0, current);
        this.animateNumber(this.elements.ammoReserve, this.lastData.ammoReserve || 0, reserve);

        // Low ammo warning
        if (current <= 5) {
            this.elements.ammo.classList.add('low-ammo');
        } else {
            this.elements.ammo.classList.remove('low-ammo');
        }

        if (reserve <= 20) {
            this.elements.ammoReserve.classList.add('low-ammo');
        } else {
            this.elements.ammoReserve.classList.remove('low-ammo');
        }
    }

    /**
     * Animate number change
     */
    animateNumber(element, from, to, duration = 300) {
        if (!element) return;
        
        from = parseFloat(from) || 0;
        to = parseFloat(to) || 0;
        
        if (from === to) {
            element.textContent = Math.round(to);
            return;
        }

        const start = performance.now();
        const diff = to - from;

        const animate = (currentTime) => {
            const elapsed = currentTime - start;
            const progress = Math.min(elapsed / duration, 1);
            
            // Easing function
            const eased = progress < 0.5 
                ? 2 * progress * progress 
                : 1 - Math.pow(-2 * progress + 2, 2) / 2;

            const current = from + (diff * eased);
            element.textContent = Math.round(current);

            if (progress < 1) {
                requestAnimationFrame(animate);
            } else {
                element.textContent = Math.round(to);
            }
        };

        requestAnimationFrame(animate);
    }

    /**
     * Add kill to killfeed
     * @param {Object} killData - {killer, victim, weapon}
     */
    addKill(killData) {
        if (!killData || !this.elements.killfeed) return;

        const killElement = document.createElement('div');
        killElement.className = 'kill-item';
        killElement.innerHTML = `
            <div class="kill-killer">${(killData.killer || 'UNKNOWN').toUpperCase()}</div>
            <div class="kill-info">
                <span class="kill-action">ELIMINATED</span>
                <span class="kill-victim">${(killData.victim || 'UNKNOWN').toUpperCase()}</span>
            </div>
        `;

        // Add to killfeed
        this.elements.killfeed.insertBefore(killElement, this.elements.killfeed.firstChild);

        // Remove after 5 seconds
        setTimeout(() => {
            killElement.classList.add('fade-out');
            setTimeout(() => {
                if (killElement.parentNode) {
                    killElement.parentNode.removeChild(killElement);
                }
            }, 300);
        }, 5000);

        // Keep only last 5 kills
        const kills = this.elements.killfeed.getElementsByClassName('kill-item');
        while (kills.length > 5) {
            this.elements.killfeed.removeChild(kills[kills.length - 1]);
        }
    }
}

// Initialize HUD
const hud = new DarkRPHUD();

// Global functions for Lua to call
window.updateHUD = function(data) {
    hud.update(data);
};

window.addKill = function(killData) {
    hud.addKill(killData);
};

// Test mode (remove in production)
if (window.location.search.includes('test')) {
    console.log('[DarkRP HUD] Test mode enabled');
    
    // Simulate data updates
    let testHealth = 100;
    let testArmor = 100;
    let testMoney = 5000;
    let testAmmo = 30;

    setInterval(() => {
        hud.update({
            health: testHealth,
            armor: testArmor,
            money: testMoney,
            job: 'Мэр города',
            salary: 250,
            ammo: testAmmo,
            ammoReserve: 120
        });
    }, 100);

    // Test controls
    document.addEventListener('keydown', (e) => {
        switch(e.key) {
            case '1': testHealth = Math.max(0, testHealth - 20); break;
            case '2': testHealth = Math.min(100, testHealth + 25); break;
            case '3': testArmor = Math.max(0, testArmor - 20); break;
            case '4': testArmor = Math.min(100, testArmor + 25); break;
            case '5': testMoney += 1000; break;
            case '6': testAmmo = Math.max(0, testAmmo - 5); break;
            case '7': 
                hud.addKill({
                    killer: 'TEST_PLAYER',
                    victim: 'TARGET_' + Math.floor(Math.random() * 100)
                });
                break;
        }
    });
}