// Configurable stats for cat races and mobs
const catStats = {
  race1: {
    hp: 100,
    defense: 10,
    attack: 20,
    speed: 0.2,
    regen: 1, // HP regen per second
    energyRegen: 1 // Energy regen per second
  },
  race2: {
    hp: 120,
    defense: 15,
    attack: 25,
    speed: 0.25,
    regen: 1.5,
    energyRegen: 1.2
  },
  race3: {
    hp: 80,
    defense: 5,
    attack: 30,
    speed: 0.3,
    regen: 0.8,
    energyRegen: 0.9
  }
};

const mobStats = {
  mouse: {
    name: 'Mouse',
    level: 1,
    hp: 100,
    defense: 5,
    attack: 1,
    speed: 0.1,
    regen: 0.333333, // HP regen per second when not chasing (1 HP every 3 sec)
    xpReward: 15,
    chaseSpeed: 0.15, // Speed when chasing
    wanderSpeed: 0.05, // Speed when wandering
    zoneMinX: 150,
    zoneMaxX: 275,
    zoneMinZ: -125,
    zoneMaxZ: 125,
    spawnPoints: [
      { x: 170, z: -90 },
      { x: 180, z: -45 },
      { x: 190, z: 0 },
      { x: 220, z: 35 },
      { x: 210, z: 80 },
      { x: 240, z: -30 }
    ]
  },
  rat: {
    name: 'Rat',
    level: 2,
    hp: 180,
    defense: 10,
    attack: 2,
    speed: 0.12,
    regen: 0.333333,
    xpReward: 30,
    chaseSpeed: 0.18,
    wanderSpeed: 0.06,
    zoneMinX: 150,
    zoneMaxX: 275,
    zoneMinZ: -125,
    zoneMaxZ: 125,
    spawnPoints: [
      { x: 175, z: 55 },
      { x: 240, z: 90 }
    ]
  }
};

// Current cat race (can be set based on player selection)
let currentCatRace = 'race1';

// Make available globally for browser
window.catStats = catStats;
window.mobStats = mobStats;
window.currentCatRace = currentCatRace;