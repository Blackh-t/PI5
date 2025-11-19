const resources = ["cpu", "mem", "disk"];
const totalBlocks = 50; // blocks per bar.


function init_bar(barID) {
  const bar = document.getElementById(barID);
  const title = document.createElement('h3');
  title.textContent = barID.toUpperCase();
  bar.appendChild(title);

  // Generate status bar.
  for (let i = 0; i < totalBlocks; i++) {
    const div = document.createElement('div');
    div.classList.add('block');
    bar.appendChild(div);
  }
}

function update_bar(barID, usagePercent) {
  const bar = document.getElementById(barID);
  const blocks = bar.children;
  const activeBlocks = Math.round(totalBlocks * usagePercent / 100);

  // Updates status bar.
  for (let i = 0; i < blocks.length; i++) {
    if (i < activeBlocks) {
      blocks[i].classList.add('active');
    } else {
      blocks[i].classList.remove('active');
    }
    
  }
}

// Init system resources stats.
const container = document.getElementById("bars");
resources.forEach(id => {
  const div = document.createElement("div");
  div.classList.add("bar");
  div.id = id;
  container.appendChild(div);

  init_bar(id);
});

// TMP random value.
setInterval(() => {
  resources.forEach(id => {
    update_bar(id, Math.random() * 100);
  })
}, 1000);

