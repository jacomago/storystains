<script>
	export let name = '';
	export let list = [
		{
			name: '',
			href: ''
		}
	];
</script>

<div class="mx-auto py-4 px-4 whitespace-no-wrap md:m-0 md:px-8">
	<h2 class="text-xl font-medium">{name}</h2>
	<ul class="mt-3">
		{#each list as item}
			<a class="hover:text-green-500" href={item.href}>
				<li class="my-1">{item.name}</li>
			</a>
		{/each}
	</ul>
</div>
