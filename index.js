"use strict";

function render_map()
{
	/** @type {HTMLCanvasElement} */
	const canvas = document.getElementById("map");
	
	const ctx = canvas.getContext("2d");
	if (ctx === null) return;
	
	const cell_size = 32;
	const zone_size = 4;
	const map_size = 26;
	
	const side_length = cell_size * zone_size * map_size;
	
	ctx.lineWidth = 1;
	ctx.strokeStyle = "red";
	ctx.textBaseline = "top";
	ctx.font = "bold " + (cell_size / 2) + "px sans-serif";
	
	for (let row = 1; row < map_size; row++)
	{
		if (row & 1)
		{
			ctx.fillStyle = "#FFFFFF09";
			ctx.fillRect(0, row * cell_size * zone_size, canvas.width, cell_size * zone_size);
		}
		
		ctx.fillStyle = "red";
		ctx.fillText(map_size - row, 0, row * cell_size * zone_size);
		
		for (let subrow = 0; subrow < zone_size; subrow++)
		{
			const y = row * (cell_size * zone_size) + subrow * cell_size;
			
			if (subrow) ctx.moveTo(cell_size * zone_size, y);
			else ctx.moveTo(0, y);
			
			ctx.lineTo(side_length + 1, y);
		}
	}
	
	const letters = "ABCDEFGHIJKLMNOPQRSTUVWXY"
	
	for (let column = 1; column < map_size; column++)
	{
		if (column & 1)
		{
			ctx.fillStyle = "#FFFFFF09";
			ctx.fillRect(column * cell_size * zone_size, 0, cell_size * zone_size, canvas.height);
		}
		
		ctx.fillStyle = "red";
		ctx.fillText(letters.at(column - 1), column * cell_size * zone_size, 0);
		
		for (let subcolumn = 0; subcolumn < zone_size; subcolumn++)
		{
			const x = column * (cell_size * zone_size) + subcolumn * cell_size;
			
			if (subcolumn) ctx.moveTo(x, cell_size * zone_size);
			else ctx.moveTo(x, 0);
			
			ctx.lineTo(x, side_length + 1);
		}
	}
	
	ctx.moveTo(0, side_length + 1);
	ctx.lineTo(side_length + 1, side_length + 1);
	ctx.lineTo(side_length + 1, 0);
	
	ctx.stroke();
}

async function main()
{
	render_map();
}

document.addEventListener("DOMContentLoaded", main);