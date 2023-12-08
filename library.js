const FontLibrary = {
    'PressStart2P': 'PressStart2P',
};

class Vector2 {
    constructor(x, y) {
        this.x = x;
        this.y = y;
    }

    static distance(v1, v2) {
        const dx = v2.x - v1.x;
        const dy = v2.y - v1.y;
        return Math.sqrt(dx * dx + dy * dy);
    }
}
  
class Color3 {
    constructor(r, g, b) {
        this.r = r;
        this.g = g;
        this.b = b;
    }
}

function calculateIntersection(lineStart, lineEnd, circleCenter, circleRadius) {
    const dX = lineEnd.x - lineStart.x;
    const dY = lineEnd.y - lineStart.y;

    const fX = lineStart.x - circleCenter.x;
    const fY = lineStart.y - circleCenter.y;

    const a = dX * dX + dY * dY;
    const b = 2 * (fX * dX + fY * dY);
    const c = fX * fX + fY * fY - circleRadius * circleRadius;

    const discriminant = b * b - 4 * a * c;

    if (discriminant >= 0) {
        const t1 = (-b - Math.sqrt(discriminant)) / (2 * a);
        const t2 = (-b + Math.sqrt(discriminant)) / (2 * a);

        const intersection1 = new Vector2(lineStart.x + t1 * dX, lineStart.y + t1 * dY);
        const intersection2 = new Vector2(lineStart.x + t2 * dX, lineStart.y + t2 * dY);

        return Vector2.distance(lineStart, intersection1) < Vector2.distance(lineStart, intersection2)
            ? intersection1
            : intersection2;
    }

    return lineEnd;
}

function getRainbowColor() {
    const frequency = 3;
    const time = Date.now() / 1000; 
    const r = Math.sin(frequency * time + 0) * 127 + 128;
    const g = Math.sin(frequency * time + 2) * 127 + 128;
    const b = Math.sin(frequency * time + 4) * 127 + 128;
    return new Color3(r.toFixed(0), g.toFixed(0), b.toFixed(0));
}
  
class Drawing {
    constructor(type) {
        this.type = type;
        this.visible = false;
        this.color = new Color3(255, 255, 255);
        this.Transparency = 0;
    }
  
    set Visible(value) {
        this.visible = value;
    }
  
    Remove(context) {
      this.visible = false;
      this.color = null;
  
      context.clearRect(0, 0, context.canvas.width, context.canvas.height);
    }
  
    set Color(color) {
      this.color = color;
    }
  }
  
class Line extends Drawing {
    constructor() {
        super("Line");
        this.From = new Vector2(0, 0);
        this.To = new Vector2(0, 0);
        this.Thickness = 1;
    }
  
    draw(context) {
        if (this.visible) {
            context.beginPath();
            context.moveTo(this.From.x, this.From.y);
            context.lineTo(this.To.x, this.To.y);
            context.strokeStyle = `rgba(${this.color.r}, ${this.color.g}, ${this.color.b}, ${1 - this.Transparency})`;
            context.lineWidth = this.thickness;
            context.stroke();
        }
    }
}

class Square extends Drawing {
    constructor() {
        super("Square");
        this.Transparency = 0;
        this.Thickness = 1;
        this.Size = new Vector2(50, 50);
        this.Position = new Vector2(0, 0);
        this.Filled = false;
    }

    draw(context) {
        if (this.visible) {
            context.beginPath();

            if (this.Filled) {
                context.fillStyle = `rgba(${this.color.r}, ${this.color.g}, ${this.color.b}, ${1 - this.Transparency})`;
                context.fillRect(this.Position.x, this.Position.y, this.Size.x, this.Size.y);
            } else {
                context.strokeStyle = `rgba(${this.color.r}, ${this.color.g}, ${this.color.b}, ${1 - this.Transparency})`;
                context.lineWidth = this.Thickness;
                context.rect(this.Position.x, this.Position.y, this.Size.x, this.Size.y);
                context.stroke();
            }
        }
    }
}

class Circle extends Drawing {
    constructor() {
        super("Circle");
        this.Transparency = 0;
        this.Thickness = 1;
        this.NumSides = 32; 
        this.Radius = 50;
        this.Filled = false;
        this.Position = new Vector2(150, 150); 
    }

    draw(context) {
        if (this.visible) {
            context.beginPath();

            if (this.Filled) {
                context.fillStyle = `rgba(${this.color.r}, ${this.color.g}, ${this.color.b}, ${1 - this.Transparency})`;
            } else {
                context.strokeStyle = `rgba(${this.color.r}, ${this.color.g}, ${this.color.b}, ${1 - this.Transparency})`;
                context.lineWidth = this.Thickness;
            }

            const angleIncrement = (2 * Math.PI) / this.NumSides;

            for (let i = 0; i < this.NumSides; i++) {
                const angle = i * angleIncrement;
                const x = this.Position.x + this.Radius * Math.cos(angle);
                const y = this.Position.y + this.Radius * Math.sin(angle);

                if (i === 0) {
                    context.moveTo(x, y);
                } else {
                    context.lineTo(x, y);
                }
            }

            context.closePath();

            if (this.Filled) {
                context.fill();
            } else {
                context.stroke();
            }
        }
    }
}

class Text extends Drawing {
    constructor() {
        super("Text");
        this.Text = "";
        this.Transparency = 0;
        this.Size = 16;
        this.Center = true;
        this.Outline = false;
        this.OutlineColor = new Color3(0, 0, 0);
        this.Font = 'PressStart2P'; 
    }

    draw(context) {
        if (this.visible) {
            context.font = `${this.Size}px ${FontLibrary[this.Font]}`;
            context.textAlign = 'center';
            context.textBaseline = 'middle';
            context.fillStyle = `rgba(${this.color.r}, ${this.color.g}, ${this.color.b}, ${1 - this.Transparency})`;

            if (this.Outline) {
                context.strokeStyle = `rgba(${this.OutlineColor.r}, ${this.OutlineColor.g}, ${this.OutlineColor.b}, ${1 - this.Transparency})`;
                context.lineWidth = 2;
                context.strokeText(this.Text, this.Position.x, this.Position.y);
            }

            context.fillText(this.Text, this.Position.x, this.Position.y);
        }
    }
}

document.addEventListener("DOMContentLoaded", function () {
    const canvas = document.getElementById("drawingCanvas");
    const context = canvas.getContext("2d");
    const Rainbow = true;

    const drawings = [];

    const espTracer = new Line();
    espTracer.Visible = true;
    espTracer.Color = new Color3(0, 0, 255);
    espTracer.Thickness = 1;
    espTracer.Transparency = 0;
    espTracer.From = new Vector2(0, 0);
    espTracer.To = new Vector2(0, 0);

    drawings.push(espTracer);

    const fovCircle = new Circle();
    fovCircle.Visible = true;
    fovCircle.Color = new Color3(0, 0, 255);
    fovCircle.Thickness = 2;
    fovCircle.Transparency = 0.3;
    fovCircle.Radius = 30;
    fovCircle.Filled = false;
    fovCircle.Position = new Vector2(300, 150);
    fovCircle.NumSides = 13;

    drawings.push(fovCircle);

    const espBox = new Square();
    espBox.Visible = true;
    espBox.Color = new Color3(0, 0, 255); 
    espBox.Thickness = 1;
    espBox.Transparency = 0;
    espBox.Size = new Vector2(200, 300);
    espBox.Position = new Vector2((canvas.width - espBox.Size.x) / 2, (canvas.height - espBox.Size.y) / 2);
    espBox.Filled = true; 

    drawings.push(espBox);

    const espName = new Text();
    espName.Visible = true;
    espName.Text = "arskware.scripts";
    espName.Position = new Vector2(100, 100);
    espName.Size = 9;
    espName.Color = new Color3(0, 0, 255);
    espName.Outline = false;
    espName.OutlineColor = new Color3(0, 0, 0);

    drawings.push(espName);

    const espInfo = new Text();
    espInfo.Visible = true;
    espInfo.Text = "69 HP | 420 Studs";
    espInfo.Position = new Vector2(100, 100);
    espInfo.Size = 7;
    espInfo.Color = new Color3(0, 0, 255);
    espInfo.Outline = false;
    espInfo.OutlineColor = new Color3(0, 0, 0);

    drawings.push(espInfo);

    function drawAll() {
        context.clearRect(0, 0, canvas.width, canvas.height);

        for (const drawing of drawings) {
            drawing.draw(context);
        }
    }

    drawAll();
    
    function setRainbow() {
        if (Rainbow == true) {
            espBox.Color = getRainbowColor();
            espTracer.Color = getRainbowColor();
            fovCircle.Color = getRainbowColor();
            espName.Color = getRainbowColor();
            espInfo.Color = getRainbowColor();
        }

        drawAll();
    }

    setInterval(setRainbow, 1);

    canvas.addEventListener("mousemove", function (event) {
        const mouseX = event.clientX - canvas.getBoundingClientRect().left;
        const mouseY = event.clientY - canvas.getBoundingClientRect().top;
        const centerBottomX = espBox.Position.x + espBox.Size.x / 2;
        const centerBottomY = espBox.Position.y + espBox.Size.y;
        const intersection = calculateIntersection(espTracer.From, new Vector2(mouseX, mouseY), fovCircle.Position, fovCircle.Radius);
    
        espTracer.To = intersection;
        espTracer.From = new Vector2(centerBottomX, centerBottomY);
        fovCircle.Position = new Vector2(mouseX, mouseY);
        espName.Position = new Vector2(centerBottomX, 260);
        espInfo.Position = new Vector2(centerBottomX, 245);
    
        drawAll();
    });
});
