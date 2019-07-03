<application>
	<fieldset>
		<label>
			<span ref="lang_selected_application"></span>
			<input type="text" ref="selected_application" class="selected_application" value={ applicationpath } readonly>
		</label>
		<label>
			<button type="button" ref="select_application" onclick={ selectApplication }></button>
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
			},

			onMounted() {
				this.refs = {
					lang_selected_application: this.$('[ref=lang_selected_application]'),
					selected_application: this.$('[ref=selected_application]'),
					select_application: this.$('[ref=select_application]'),
					lang_set_stream_title: this.$('[ref=lang_set_stream_title]'),
					stream_title: this.$('[ref=stream_title]'),
					lang_set_stream_game: this.$('[ref=lang_set_stream_game]'),
					stream_game: this.$('[ref=stream_game]')
				}

				this.refs.lang_selected_application.innerText = this.titlechanger.i18n.__('Selected application:')
				this.refs.select_application.innerText = this.titlechanger.i18n.__('Select an application')
				this.refs.lang_set_stream_title.innerText = this.titlechanger.i18n.__('Change stream title to:')
				this.refs.lang_set_stream_game.innerText = this.titlechanger.i18n.__('Change stream game to:')
			},

			onBeforeUpdate() {
				this.applicationpath = this.props.app.path
				this.streamtitle = this.props.app.title
				this.streamgame = this.props.app.game
			},

			selectApplication() {
				let files = dialog.showOpenDialog(BrowserWindow.getFocusedWindow(), {
					title: this.titlechanger.i18n.__('Select an application'),
					filters: [{name: 'Executeable files', extensions: ['dll', 'exe']}],
					properties: [ 'openFile' ]
				})
				if(files != null && files.hasOwnProperty('length') && files.length > 0) {
					this.applicationpath = files[0]
					this.props.app.path = files[0]
				}
				this.update()
			}
		}
	</script>
</application>