<script>
	import Navbar from '../components/Navbar.svelte';

	import '../app.css';
	import Footer from '../components/Footer.svelte';
</script>

<Navbar />

<div class="grow self-center mt-16 mb-16 px-4">
	<slot />
</div>

<Footer />
