import { ArrowLeft, User, Shield, Bell, HelpCircle, LogOut, Eye, History } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Switch } from "@/components/ui/switch"
import Link from "next/link"

export default function ProfilePage() {
  return (
    <main className="flex min-h-screen flex-col bg-white pb-16">
      {/* Header */}
      <div className="sticky top-0 bg-white border-b border-gray-200 z-10">
        <div className="max-w-md mx-auto px-4 py-3 flex items-center">
          <Link href="/">
            <Button variant="ghost" size="icon" className="mr-2">
              <ArrowLeft className="h-5 w-5 text-blue-900" />
            </Button>
          </Link>
          <h1 className="text-xl font-bold text-blue-900">Profile</h1>
        </div>
      </div>

      <div className="max-w-md mx-auto w-full px-4 py-6">
        {/* User Profile */}
        <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-4 mb-6">
          <div className="flex items-center">
            <div className="w-16 h-16 rounded-full bg-blue-100 flex items-center justify-center">
              <User className="h-8 w-8 text-blue-600" />
            </div>
            <div className="ml-4">
              <h2 className="text-lg font-semibold text-blue-900">John Doe</h2>
              <p className="text-sm text-gray-500">john.doe@example.com</p>
              <Button variant="link" className="text-blue-600 p-0 h-auto text-sm">
                Edit Profile
              </Button>
            </div>
          </div>
        </div>

        {/* Settings */}
        <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-4 mb-6">
          <h3 className="text-md font-semibold text-blue-900 mb-4">Settings</h3>

          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <div className="flex items-center">
                <div className="w-8 h-8 rounded-full bg-blue-100 flex items-center justify-center mr-3">
                  <Bell className="h-4 w-4 text-blue-600" />
                </div>
                <div>
                  <p className="text-sm font-medium text-gray-800">Notifications</p>
                  <p className="text-xs text-gray-500">Receive scan reminders and updates</p>
                </div>
              </div>
              <Switch defaultChecked />
            </div>

            <div className="flex items-center justify-between">
              <div className="flex items-center">
                <div className="w-8 h-8 rounded-full bg-blue-100 flex items-center justify-center mr-3">
                  <Shield className="h-4 w-4 text-blue-600" />
                </div>
                <div>
                  <p className="text-sm font-medium text-gray-800">Data Privacy</p>
                  <p className="text-xs text-gray-500">Store scans locally only</p>
                </div>
              </div>
              <Switch />
            </div>

            <div className="flex items-center justify-between">
              <div className="flex items-center">
                <div className="w-8 h-8 rounded-full bg-blue-100 flex items-center justify-center mr-3">
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    width="16"
                    height="16"
                    viewBox="0 0 24 24"
                    fill="none"
                    stroke="currentColor"
                    strokeWidth="2"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    className="text-blue-600"
                  >
                    <path d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364-.7071-.7071M6.34315 6.34315l-.70711-.70711m12.72796.00005-.7071.70711M6.3432 17.6569l-.70711.7071"></path>
                    <circle cx="12" cy="12" r="4"></circle>
                  </svg>
                </div>
                <div>
                  <p className="text-sm font-medium text-gray-800">Dark Mode</p>
                  <p className="text-xs text-gray-500">Switch to dark theme</p>
                </div>
              </div>
              <Switch />
            </div>
          </div>
        </div>

        {/* Professional Mode */}
        <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-4 mb-6">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-md font-semibold text-blue-900">Professional Mode</h3>
            <Switch defaultChecked />
          </div>

          <p className="text-sm text-gray-600 mb-3">
            Enable advanced features for healthcare professionals, including detailed metrics, clinical terminology, and
            downloadable reports.
          </p>

          <div className="bg-blue-50 p-3 rounded-lg">
            <p className="text-xs text-blue-800">
              Professional mode is enabled. You now have access to advanced diagnostic tools and detailed reports.
            </p>
          </div>
        </div>

        {/* Support */}
        <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-4 mb-6">
          <h3 className="text-md font-semibold text-blue-900 mb-4">Support</h3>

          <div className="space-y-3">
            <Button variant="ghost" className="w-full justify-start text-gray-700">
              <HelpCircle className="h-4 w-4 mr-2 text-blue-600" />
              Help & FAQ
            </Button>

            <Button variant="ghost" className="w-full justify-start text-gray-700">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                width="16"
                height="16"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                strokeWidth="2"
                strokeLinecap="round"
                strokeLinejoin="round"
                className="mr-2 text-blue-600"
              >
                <path d="M21 11.5a8.38 8.38 0 0 1-.9 3.8 8.5 8.5 0 0 1-7.6 4.7 8.38 8.38 0 0 1-3.8-.9L3 21l1.9-5.7a8.38 8.38 0 0 1-.9-3.8 8.5 8.5 0 0 1 4.7-7.6 8.38 8.38 0 0 1 3.8-.9h.5a8.48 8.48 0 0 1 8 8v.5z"></path>
              </svg>
              Contact Us
            </Button>

            <Button variant="ghost" className="w-full justify-start text-gray-700">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                width="16"
                height="16"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                strokeWidth="2"
                strokeLinecap="round"
                strokeLinejoin="round"
                className="mr-2 text-blue-600"
              >
                <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path>
                <polyline points="16 17 21 12 16 7"></polyline>
                <line x1="21" y1="12" x2="9" y2="12"></line>
              </svg>
              Share Feedback
            </Button>
          </div>
        </div>

        <Button variant="outline" className="w-full border-red-200 text-red-600 mt-4">
          <LogOut className="h-4 w-4 mr-2" />
          Sign Out
        </Button>
      </div>

      {/* Navigation Bar */}
      <div className="fixed bottom-0 left-0 right-0 bg-white border-t border-gray-200">
        <div className="max-w-md mx-auto flex justify-around py-4">
          <Link href="/" className="flex flex-col items-center text-gray-400">
            <Eye className="h-6 w-6" />
            <span className="text-xs mt-1">Home</span>
          </Link>
          <Link href="/history" className="flex flex-col items-center text-gray-400">
            <History className="h-6 w-6" />
            <span className="text-xs mt-1">History</span>
          </Link>
          <Link href="/profile" className="flex flex-col items-center text-blue-900">
            <User className="h-6 w-6" />
            <span className="text-xs mt-1">Profile</span>
          </Link>
        </div>
      </div>
    </main>
  )
}

