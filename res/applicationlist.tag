<applicationlist>
	
	<application each={ app in applications } app={ app } addon={ titlechanger }></application>
	<button ref="addapp"></button>
	<button ref="saveapps"></button>

	<script>
		export default {
			onBeforeMount() {
				this.applications = []
				this.titlechanger = this.props.addon
				this.makeAccessible()
			},

			onMounted() {
				this.refs = {
					addapp: this.$('[ref=addapp]'),
					saveapps: this.$('[ref=saveapps]')
				}

				this.refs.addapp.innerHTML = this.titlechanger.i18n.__('Add application')
				this.refs.saveapps.innerHTML = this.titlechanger.i18n.__('Save settings')

				this.refs.addapp.onclick = this.addapp
				this.refs.saveapps.onclick = this.saveapps

				this.reloadsettings()
			},

			addapp() {
				this.applications.push({path: '', title: '', game: ''})
				this.update()
			},

			saveapps() {
				this.titlechanger.saveApplications()
			},

			reloadsettings() {
				this.applications = []
				this.update()
				this.applications = this.titlechanger.settings
				this.update()
			},

			setRunningApps(apps) {
				this.$$('application').forEach((t) => {
					t._tag.setRunningApps(apps)
				})
			}
		}
	</script>
</applicationlist>