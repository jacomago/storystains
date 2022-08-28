/** @type {import('tailwindcss').Config} */
module.exports = {
	content: ['./src/**/*.{html,js,svelte,ts,svx}'],
	theme: {
		fontFamily: {
			sans: ['"Libre Baskerville"', 'serif'],
			display: ['"Special Elite"']
		},
		colors: {
			paper: '#ded2c9ff'
		},
		extend: {}
	},
	plugins: []
};
