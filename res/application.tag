<application>
	<fieldset>
		<label>
			<span ref="lang_selected_application"></span>
			<input type="text" ref="selected_application" class="selected_application" value={ applicationpath } readonly>
		</label>
		<label ref="select_running_label">
			<select ref="select_running" onchange={ changedRunning }>
				<option value="">---</option>
				<option each={ app in runningApps }>{ app }</option>
			</select>
			<small ref="lang_select_running_desc"></small>
		</label>
		<label>
			<button type="button" ref="select_application" onclick={ selectApplication }></button>
			<button type="button" ref="select_running_btn" onclick={ selectRunning }></button>
		</label>

		<label>
			<span ref="lang_set_stream_title"></span>
			<input type="text" ref="stream_title" value={ streamtitle } class="stream_title">
		</label>
		<label>
			<span ref="lang_set_stream_game"></span>
			<input type="text" ref="stream_game" value={ streamgame } class="stream_game">
		</label>
	</fieldset>

	<script>
		const {BrowserWindow, dialog} = require('electron').remote
		export default {
			onBeforeMount() {
				this.titlechanger = this.props.addon

				this.applicationpath = this.props.app.path
				this.streamtitle = this.props.app.title
				this.streamgame = this.props.app.game
				this.runningApps = []

				this.makeAccessible()
			},

			onMounted() {
				this.refs = {
					lang_selected_application: this.$('[ref=lang_selected_application]'),
					selected_application: this.$('[ref=selected_application]'),
					select_application: this.$('[ref=select_application]'),
					lang_set_stream_title: this.$('[ref=lang_set_stream_title]'),
					stream_title: this.$('[ref=stream_title]'),
					lang_set_stream_game: this.$('[ref=lang_set_stream_game]'),
					stream_game: this.$('[ref=stream_game]'),

					select_running_label: this.$('[ref=select_running_label]'),
					select_running: this.$('[ref=select_running]'),
					select_running_btn: this.$('[ref=select_running_btn]'),
					lang_select_running_desc: this.$('[ref=lang_select_running_desc]')
				}

				this.refs.lang_selected_application.innerText = this.titlechanger.i18n.__('Selected application:')
				this.refs.select_application.innerText = this.titlechanger.i18n.__('Select an application')
				this.refs.lang_set_stream_title.innerText = this.titlechanger.i18n.__('Change stream title to:')
				this.refs.lang_set_stream_game.innerText = this.titlechanger.i18n.__('Change stream game to:')
				this.refs.select_running_btn.innerText = this.titlechanger.i18n.__('Select a running process')
				this.refs.lang_select_running_desc.innerText = this.titlechanger.i18n.__('You need to join your channel in order to get a list of running processes. The list refreshes every 15 seconds.')

				this.refs.select_running_label.style.display = 'none'
			},

			onBeforeUpdate() {
				this.applicationpath = this.props.app.path
				this.streamtitle = this.props.app.title
				this.streamgame = this.props.app.game
			},

			selectApplication() {
				let files = dialog.showOpenDialogSync(BrowserWindow.getFocusedWindow(), {
					title: this.titlechanger.i18n.__('Select an application'),
					filters: [{name: 'Executeable files', extensions: ['dll', 'exe']}],
					properties: [ 'openFile' ]
				})
				if(files != null && files.hasOwnProperty('length') && files.length > 0) {
					this.applicationpath = files[0]
					this.props.app.path = files[0]
				}
				this.update()
			},

			selectRunning() {
				this.refs.select_running_label.style.display = 'block'
				this.refs.select_running_btn.style.display = 'none'
			},

			changedRunning() {
				this.applicationpath = this.refs.select_running.value
				this.props.app.path = this.applicationpath
				this.refs.selected_application.value = this.applicationpath
			},

			setRunningApps(apps) {
				this.runningApps = apps
				this.update()
			}
		}
	</script>
</application>