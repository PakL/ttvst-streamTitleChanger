<applicationlist>
	
	<application each={ app in applications } no-reorder app={ app }></application>
	<button ref="addapp"></button>
	<button ref="saveapps"></button>

	<script>
		const self = this
		this.applications = []
		this.titlechanger = null

		this.on('mount', () => {
			self.titlechanger = Tool.addons.getAddon('streamTitleChanger')
			self.refs.addapp.innerHTML = self.titlechanger.i18n.__('Add application')
			self.refs.saveapps.innerHTML = self.titlechanger.i18n.__('Save settings')

			self.refs.addapp.onclick = self.addapp
			self.refs.saveapps.onclick = self.saveapps

			self.reloadsettings()
		})

		addapp() {
			self.applications.push({path: '', title: '', game: ''})
			self.update()
		}

		saveapps() {
			self.titlechanger.saveApplications()
		}

		reloadsettings() {
			self.applications = self.titlechanger.settings
			self.update()
		}
	</script>
</applicationlist>