<script>
	import FooterList from './FooterList.svelte';
	const footer_data = [
		{
			name: 'Navigation',
			list: [
				{
					name: 'About',
					href: '/about'
				}
			]
		},
		{
			name: 'Social',
			list: [
				{
					name: 'Twitter',
					href: 'https://twitter.com/jacomago'
				},
				{
					name: 'Github',
					href: 'https://github.com/jacomago/'
				}
			]
		}
	];
</script>

<footer class="py-12 bg-gray-100 min-w-full mt-16">
	<div class="flex flex-wrap mt-8 px-4 md:flex-no-wrap md:justify-center">
		{#each footer_data as data}
			<FooterList name={data.name} list={data.list} />
		{/each}
	</div>

	<div class="mt-12">
		<div class="text-center my-2">
			<a
				class="hover:text-green-500"
				href="https://creativecommons.org/licenses/by-sa/4.0/legalcode">© 2022</a
			> Sky Brewer
		</div>

		<div class="text-xs text-center">
			Made with <a class="hover:text-green-500" href="https://svelte.dev/">Svelte</a> and
			<a class="hover:text-green-500" href="https://tailwindcss.com/">Tailwind</a>
		</div>
	</div>
</footer>
