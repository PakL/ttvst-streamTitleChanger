"use strict"

const path = require("path")
const {spawn} = require('child_process')
const UIPage  = require(path.dirname(module.parent.filename) + '/../mod/uipage')
const fs = require('fs')

class StreamTitleChanger extends UIPage {

	constructor(tool, i18n) {
		super('Stream Title Changer')

		this.tool = tool
		this.i18n = i18n
		this.contentElement = null
		this.settings = tool.settings.getJSON('streamtitlechanger', [])
		this.timer = null
		this.psspath = ''
		this.ls = null

		this.lastactiveknown = -1

		let appTag = fs.readFileSync(__dirname.replace(/\\/g, '/') + '/res/application.tag', { encoding: 'utf8' })
		let code = riot.compileFromString(appTag).code
		riot.inject(code, 'application', document.location.href)

		let applistTag = fs.readFileSync(__dirname.replace(/\\/g, '/') + '/res/applicationlist.tag', { encoding: 'utf8' })
		code = riot.compileFromString(applistTag).code
		riot.inject(code, 'applicationlist', document.location.href)

		this.applicationlist = document.createElement('applicationlist')

		this.contentElement = document.createElement('div')
		this.contentElement.style.padding = '10px'
		this.contentElement.appendChild(this.applicationlist)
		document.querySelector('#contents').appendChild(this.contentElement)

		riot.mount(this.applicationlist, { addon: this })

		console.log('[StreamTitleChanger] Loading monitoring script into temp folder')
		try {
			let script = fs.readFileSync(path.join(__dirname, 'processmonitor.ps1'), {encoding: 'utf8'})
			this.psspath = path.join(process.env.TEMP, 'processmonitor.ps1')
			fs.writeFileSync(this.psspath, script)
			console.log('[StreamTitleChanger] ' + this.psspath + ' created')
		} catch(e) {
			this.psspath = ''
			this.tool.ui.showErrorMessage(e)
		}

		const self = this
		let cockpit = this.tool.ui.findPage('Cockpit');
		if(cockpit != null) {
			cockpit.on('channelopen', () => {
				if(cockpit.openChannelObject.login == this.tool.auth.username && this.psspath.length > 0) {
					this.startProcessMonitor()
				}
			})
			cockpit.on('channelleft', () => {
				if(self.ls != null) {
					self.ls.kill()
					console.log('[StreamTitleChanger] Stopping monitoring script')
					self.ls = null
				}
			})
		}

		this.tool.on('exit', () => {
			if(self.ls != null) {
				self.ls.kill()
			}
			if(self.psspath.length > 0) {
				fs.unlinkSync(self.psspath)
			}
		})
	}

	get icon() {
		return 'Ticket'
	}

	startProcessMonitor() {
		const self = this
		console.log('[StreamTitleChanger] Spawning Powershell with monitoring script')
		this.ls = spawn('powershell', ["-ExecutionPolicy", "Bypass","-File", this.psspath])
		this.ls.stdout.setEncoding('utf8')
		let dataChunk = ''
		this.ls.stdout.on('data', function(stdout) {
			dataChunk += stdout.toString()
			if(dataChunk.endsWith('\n###')) {
				self.checkProcess(self.cleanData(dataChunk))
				dataChunk = ''
			}
		});
		this.ls.on('error', (err) => {
			self.tool.ui.showErrorMessage(err)
		})
	}

	cleanData(dataChunk) {
		let lines = dataChunk.split('\n')
		let apps = []

		for(let i = 0; i < lines.length; i++) {
			let line = lines[i].trim()
			if(line == '###') continue
			if(apps.indexOf(line) < 0) {
				apps.push(line)
			}
		}

		return apps
	}

	checkProcess(cmdpath) {
		this.applicationlist._tag.setRunningApps(cmdpath)

		let newSettings = -1
		for(let i = 0; i < this.settings.length; i++) {
			if(cmdpath.indexOf(this.settings[i].path) >= 0) {
				newSettings = i
			}
		}

		if(newSettings >= 0 && this.lastactiveknown != newSettings) {
			let update = {}
			if(this.settings[newSettings].title.length > 0) {
				update.status = this.settings[newSettings].title
			}
			if(this.settings[newSettings].game.length > 0) {
				update.game = this.settings[newSettings].game
			}

			this.lastactiveknown = newSettings
			
			this.tool.ui.showErrorMessage(new Error(
				this.i18n.__('{{game}} was detected. Stream information are being changed according to your settings.', {game: path.basename(this.settings[newSettings].path)})
				+ '\n'
				+ this.i18n.__('This message hides in 5 seconds.')
			), true)
			console.log('[StreamTitleChanger] ' + path.basename(this.settings[newSettings].path) + ' is running. Stream information changing...')
			this.tool.twitchapi.updateChannel(this.tool.cockpit.openChannelId, update, () => {
				console.log('[StreamTitleChanger] Done.')
			})
		}
	}

	saveApplications() {
		let applications = this.contentElement.querySelectorAll('application')
		let applicationsSettings = []
		for(let i = 0; i < applications.length; i++) {
			let app_path = applications[i].querySelector('.selected_application').value
			let str_title = applications[i].querySelector('.stream_title').value
			let str_game = applications[i].querySelector('.stream_game').value

			if(app_path.length > 0 && (str_title.length > 0 || str_game.length > 0)) {
				applicationsSettings.push({path: app_path, title: str_title, game: str_game})
			}
		}

		this.lastactiveknown = -1
		this.settings = applicationsSettings
		this.tool.settings.setJSON('streamtitlechanger', this.settings)
		this.contentElement.querySelector('applicationlist')._tag.reloadsettings()
	}

	open() {
		this.contentElement.style.display = 'block'
	}

	close() {
		this.contentElement.style.display = 'none'
	}

}
module.exports = StreamTitleChanger